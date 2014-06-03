# Automatic deployments
Servers can be deployed to automatically using GitHub deploy hooks.

## Config
Before a server can be deployed to, you must configure it in
`server/config/<env>.json` with a 'deploy' attribute, containing:

**tags**: An array of strings that allow your server to be identified
as a deploy target, e.g. ['ad_staging', 'small_instance']. Tags can be
useful to deploy to various servers at the same time, along with the more standard
server name, which is set in the top-level configuration attribute 'server.name'.
**NB: hyphens (-) are not allowed in tags.**

**github authentication**: To notify about deployment, your server must
authenticate with github. To do this, create an auth token on GitHub:
http://developer.github.com/v3/#authentication
Then, modify your config to include these credentials:

```json
  "deploy": {
    "tags": ["lovely-staging-server"],
    "github": {
      "password": "x-oauth-basic",
      "username": "<your-auth-token>"
    }
  }
```

## GitHub Deploy hooks
Servers must be configured to listen to the creation of tags on Github:

  1. Add a WebHook [service hook](https://github.com/unepwcmc/NRT/settings/hooks)
     that points at your server's deploy route
     (`http://youdomain.com/deploy`).

Github will notify the server when a new tag is created. At this point, the server
will inspect the tag name to see if it matches:

    <server-name>-<new-feature-name>-<id>

If <server-name> is the same as 'server_name' specified in
`config/<env>.json`, the application will automatically
pull the new code and update the server's local repository.
**Make sure you are running your application with `forever`
or it will not restart after a deploy**.

## The deploy command
To deploy, run the deploy command on your local machine:

    cd server && npm run-script deploy

This will ask for the tags (or server name) you want to deploy to, and
what the feature introduces, and then create a tag. Once this tag has been
pushed, the Github deploy hooks will take care of streaming the status of the
spawn deployments back to the deploy command, ending with a summary of the deployment(s).
