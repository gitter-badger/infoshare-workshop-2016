# infoshare-workshop-2016

[![Join the chat at https://gitter.im/AirHelp/infoshare-workshop-2016](https://badges.gitter.im/AirHelp/infoshare-workshop-2016.svg)](https://gitter.im/AirHelp/infoshare-workshop-2016?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the repository for the InfoShare workshop of AirHelp for fetching and parsing itinerary information from mailboxes.

## Setup

You need to have ruby installed on your machine to run the code from the repository. If you don't have ruby you can try [rbenv](https://github.com/rbenv/rbenv) and install ruby 2.3.

You will need a google oauth2 application credentials in order to run the example. You can create credentials in the Google's Developers Console in the [Oauth Client](https://console.developers.google.com/apis/credentials/oauthclient) section. Create a "Web application" and set the "Authorized redirect URIs" to `<ngrok_https_address/auth/google_oauth2/callback`.

After creating the application you need to copy the `Client ID` and the `Client secret` in the .env file and restart the app.

You need to enable [Google+ API from the console](https://console.developers.google.com/apis/api/plus/overview) to be able to access information about the users that login into your app.

You also need to enable [GMail API from the console](https://console.developers.google.com/apis/api/gmail/overview) so that you can access the emails of the users.
