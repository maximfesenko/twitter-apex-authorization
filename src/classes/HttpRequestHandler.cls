/**
 * @description Handler class for making http requests.
*/
public without sharing class HttpRequestHandler {

	private HttpRequest request;

	public HttpRequestHandler(HttpRequest p_request) {

		this.request = p_request;
	}

	/**
	 * @description Call http request with prepared data
	 * @return HttpResponse is http response with all required data.
	*/
	public HttpResponse call() {

		try {

			return new Http().send(this.request);

		} catch(Exception ex) {

			throw new TwitterAuthorization.TwitterException(ex);
		}
	}
}