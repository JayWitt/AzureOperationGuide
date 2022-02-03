# Azure Application Gateway Rewrite Rules Guide

Listed below are some common examples of re-write rules along with some good notes to keep in mind:

* Note that if the value in the rewrite rule doesn’t return anything then the whole header is excluded. This means that if you add a header that has “newHeader” = “{var_host}” and the host variable doesn’t have any value it in, newHeader will not even be shown in the results.


## Add Client IP as a new header
You can use the server variable called "client_ip" (which translates to "{var_client_ip}" when you add it to the portal) to add the IP address of the client from which the application gateway received the request.

![Add Client IP](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/clientip.png)

## Add IP address of the Application Gateway
The App Gateway can't add it's own IP address to the headers but there are alternative ways of achieving the same thing. In some cases, the server variable called "host" (which translated to "{var_host}" when you add it to the portal) can be used to show the host that is used when accessing the application gateway.
**Note**:This will depend on the host name that is being used as part of the listener.

![Add Client IP](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/gatewayname.png)

## Add Request URI as a Header
You can use the server variable named "request_uri" (which translates to "{var_request_uri"} when you add it to the portal) to add the part of the URL that is after the host. 
**Note**: The request_uri does include the query string. As an example: The request url for the following URL  http://contoso.com:8080/article.aspx?id=123&title=fabrikam would be article.aspx?id=123&title=fakrikam

![Add Client IP](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/requesturi.png)

## Adding information from existing headers
You can also use information from existing headers by pre-pending them with "http_req_". As an example, you can include in the referer into a separate header by adding in "{http_req_referer}" to the value.
**Note**: The exampe here adds in the additional hypons more to make sure that there is always a value in the header. If not and the referer is empty, it would not show the Jays-Referer header.

![Add Client IP](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/referer.png)