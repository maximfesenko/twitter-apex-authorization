public class TwitterHandler {

    private TwitterSettings__c settings;

    public TwitterHandler() {
        this.settings = TwitterSettings__c.getOrgDefaults();
    }

    public String searchUsers() {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(TwitterManager.TWITTER_API_URL + '/users/search.json?q=Twitter%20API&page=1&count=3');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        Map<String,String> parameters = TwitterService.prepareHeaderParams(this.settings);
        parameters.put('oauth_token', this.settings.AccessToken__c);

        String authorizationHeader = TwitterService.generateAuthorizationHeader(request, this.settings, parameters);
        request.setHeader('Authorization', authorizationHeader);

        HttpResponse response = new HttpRequestHandler(request).call();

        if (String.isNotEmpty(response.getBody())) {
            System.assert(false, '---' + response.getBody());
        }
        return response.getBody();
    }
}