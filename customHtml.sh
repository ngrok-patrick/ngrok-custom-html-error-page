#!/bin/bash

if [  -z "${NGROK_API_KEY}" ]; then

    RED='\033[0;31m'
NC='\033[0m' # No Color

    echo ""
    printf "${RED}NGROK_API_KEY is not set${NC}, please get an API Key from ngrok. https://dashboard.ngrok.com/api\n"

    echo "  And, set the value like this:"
    echo "       export NGROK_API_KEY=\"your_ngrok_API_key\" ./$(basename "$0")"
    echo "  or, pass the apikey as a Parameter like this:"
    echo "      NGROK_API_KEY=\"Your Key\" ./$(basename "$0") \"edghts_id*\" \"{\\\"body\\\":\\\"Custom Body Here\\\"}"
    echo ""
    exit 0
fi


if [ ! -f "$2" ]; then
  echo "The last argument should be a HTML file"
  echo "  example: $(basename "$0") [EdgeID] [htmlfile.html]"
  exit 1
fi



function ngrokPatch() {    

    URI=$(jq -r '.url' <<<$1)
    PATCH_APIKEY=$(jq -r '.apikey' <<<$1)
    PATCH_DATA=$(jq -r '.data' <<<$1)

    resp=$(curl --location --request PATCH "$URI" -w "{\"http_code\":%{http_code}}" --header "Authorization: Bearer ${PATCH_APIKEY}" --header "Content-Type: application/json" --header "Ngrok-Version: 2" --data "$PATCH_DATA")

    http_code=$(jq -r '.http_code | select( . != null )' <<<"${resp}")
    if [[ "${http_code}" -ne 200 ]]; then
      echo "HTTP Error Code: ${http_code}"
      echo "Response: ${resp}"
      exit 1
    else 
    resp=$(jq 'del(.http_code)' <<<"${resp}") # Huh, leaves extra "{}" in the string ?
    fi

    #Then, add Filter (If needed/wanted)

    echo $resp
}

function ngrokGet() {

  GET_NEXTPAGE_URI=$(jq -r '.url' <<<$1)
  GET_APIKEY=$(jq -r '.apikey' <<<$1)
  GET_FILTER=$(jq -r '.filter' <<<$1)

  if [[ "$GET_FILTER" == "null" ]]; then
    GET_FILTER="" 
  fi

  while [[ -n "${GET_NEXTPAGE_URI}" ]]; do
    resp=$(curl -sS -H "authorization: Bearer ${GET_APIKEY}" -H "ngrok-version: 2" -w "{\"http_code\":%{http_code}}" "${GET_NEXTPAGE_URI}" | jq -s add)

    http_code=$(jq -r '.http_code | select( . != null )' <<<"${resp}")
    if [[ "${http_code}" -ne 200 ]]; then
      echo "HTTP Error Code: ${http_code}"
      echo "Response: ${resp}"
      exit 1
    fi
    GET_NEXTPAGE_URI=$(jq -r '.next_page_uri | select( . != null )' <<<"${resp}")

    results+=$(jq "${GET_FILTER}" <<<"${resp}")

  done
  results=$(jq -s . <<< "${results}")

  echo "${results}"

}
OUTPUT=$(ngrokGet '{"url":"https://api.ngrok.com/edges/https/'"$1"'" ,"apikey": "'"$NGROK_API_KEY"'"}')
BKDFO=$(echo "${OUTPUT}" | jq -r  '.[0].routes[0].backend.backend.uri')
OUTPUT=$(ngrokGet '{"url":"'"$BKDFO"'" ,"apikey": "'"$NGROK_API_KEY"'"}')
BKHDR=$(jq -r '.[] | .backends[] | select(startswith("bkdhr"))' <<<"${OUTPUT}")

PATCH_DATA=$2
cat $2 | sed 's/\"/\\\\\\"/g' | sed 's/\!/\\\!/g' | tr -d '\n'  > $2.tmp 
PATCH_DATA=$(cat $2.tmp | xargs)
rm $2.tmp
RESULT="{\"body\": \"${PATCH_DATA}\"}"

OUTPUT=$(ngrokPatch '{"url": "https://api.ngrok.com/backends/http_response/'"$BKHDR"'","apikey": "'"$NGROK_API_KEY"'","data": '"$RESULT"'}')


