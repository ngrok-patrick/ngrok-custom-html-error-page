# ngrok-custom-html-errorpage

This is a simple example in Bash Script, of using the ngrok API to generate Custom Error messages.

In some situations developer might want to change the default error message displayed
when the ngrok agent is not running, or they do not want their Users to know that 
they are using ngrok.

This simple example will upload a HTML Error Page to ngrok, and register the page with
an ngrok HTML Edge in this example.

## Prerequisites

You will need a Bash Shell and make sure `jq` and `curl` is installed for this Bash Script to work.

## How do I run this
First you need to obtain your API Key from your ngrok Dashboard: https://dashboard.ngrok.com/api

**Then** you need to set an Environment Variable to the ngork API Key value. You
can simply export the value like so from the Shell: `export NGROK_API_KEY [yourKey]`

Create a new **HTML Edge** in the **ngrok Dashboard** or from the API, and obtain the **Edge ID**. In
the ngrok dashboard there is a shortcut that will copy the value to your Clipboard in your 
Browser:

<img width="495" alt="image" src="https://github.com/ngrok-patrick/ngrok-custom-html-errorpage/assets/112023765/f2a9bbf0-aecb-4bdf-bfb9-b185135cbeaa">

`./customHtml.sh edghts_2UiGMp2tx4F4MZqlZ8tMRvbzgzH ./index.html`

Assuming you cloned the Repo., and ran the script, if you browse to the Domain assigned to
your Edge, and the ngrok Agent is not running, you should see the Custom HTML Error page
from this repo.

## Final Thoughts

This is a simple REST API request, so you can run it from almost any backend. Since there are not
many examples of this on the Web, I kept the example very simple, and just used very simple tools.

If you want to see other examples or have any questions about this, feel free to reach out to me.

patrick@ngrok.com
