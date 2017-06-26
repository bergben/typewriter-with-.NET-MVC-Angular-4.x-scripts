# typewriter-with-.NET-MVC-Angular-4.x-scripts
Scripts to automatically create TypeScript interfaces and Angular 4.x services from .NET MVC backend
## Install
Copy all the files in the related folders of your project. (The typewriter template files where you want to place them in your angular project).

## Usage
Mark controllers with `[TSGenerate]` to generate services out of them.

```
namespace WebApp.Controllers
{
    [TSGenerate]
    public class SomeController
    {
    
    [...]
```

Provide a ResponseType for all methods a function should be generated for:

```
    [ResponseType(typeof(SomeViewModel[]))]
    public IHttpActionResult Get(int id)
    {
       [...]
    }
```

Create a file models.ts in the folder `models/` which exports all generated models (needed for imports to work in generated models).

```
export * from './some.model';
export * from './other.model';
[...]
```

Manually import the generated services as providers in your `app.module.ts`


## Use the Angular CLI for building processes and development

Use the Angular CLI to create a project.
Use `ng serve` for development. 
Run the backend using IIS, add the following to your Global.asax to allow CORS (requests from your local `ng serve` server) and  for authorization:
```
        protected void Application_BeginRequest()
        {
            if (IsDebuggingService.RunningInDebugMode())
            {
                //Running in Debug Mode

                //allow CORS to allow the local running angular app to access the local running backend API
                var context = HttpContext.Current;
                var response = context.Response;

                if(context.Request.Headers["Origin"] != null){
                    // enable CORS
                    response.Headers.Remove("Access-Control-Allow-Origin");
                    response.AddHeader("Access-Control-Allow-Origin", context.Request.Headers["Origin"]);

                    response.Headers.Remove("Access-Control-Allow-Credentials");
                    response.AddHeader("Access-Control-Allow-Credentials", "true");

                    response.Headers.Remove("Access-Control-Allow-Headers");
                    response.AddHeader("Access-Control-Allow-Headers", "Content-Type");

                    response.Headers.Remove("Access-Control-Allow-Methods");
                    response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
                    if (Request.HttpMethod == "OPTIONS")
                    { //valide Preflight request (RequestMethod OPTIONS) which is executed by the browser if content-type of api request is set to application/json
                        Response.Flush();
                    }
                }
            }
        }

        protected void Application_AuthenticateRequest(object sender, EventArgs args)
        {
            #if DEBUG
                if (HttpContext.Current.Request.Cookies["isNgServe"]!=null)
                {
                    //When testing with ngServe automatically generate Identity for Authentication purposes
                        HttpContext.Current.User = new GenericPrincipal(new GenericIdentity("Bert"), new string[] { });
                }
            #endif
        }
```

Set the cookie `isNgServe` to true when using environment production in your `app.component.ts`.
```
import { environment } from '../environments/environment';

[...]

export class AppComponent {
    constructor() {
        if (!environment.production) {
            //set cookie for testing with ng serve authorization
            document.cookie = "isNgServe=true";
        }
    }
}

```

Add the url of your local backend to your `environment.ts` file as `apiBaseUrl`:
```
export const environment = {
    production: false,
    apiBaseUrl: "http://localhost:55189/",
};
```
set `apiBaseUrl` to "" in `environment.prod.ts`:
```
export const environment = {
    production: true,
    apiBaseUrl: "",
};
```

<hr />

Store all assets in `src/app/assets`.
Add the following as npm scripts to your `package.json`:
```
        "ngbuild": "ng build --prod",
        "move-assets": "move /y \"..\\Scripts\\angularApp\\assets\" \"..\\assets\"",
        "move-index": "move /y \"..\\Scripts\\angularApp\\index.html\" \"..\\Views\\Shared\\_GeneratedTagsPartial.cshtml\"",
        "clean": "if exist \"..\\Scripts\\angularApp\" rmdir \"..\\Scripts\\angularApp\" /s /q && if exist \"..\\assets\" rmdir \"..\\assets\" /s /q",
        "copy": "xcopy \"dist\" \"..\\Scripts\\angularApp\" /i /s /r /y /c",
        "build": "npm run ngbuild && npm run clean && npm run copy && npm run move-index && npm run move-assets"
```

Run `npm run build` to build for production:
The generated angular JS will be created in `/Scripts/angularApp`.
The assets will be copied to `/assets`.
A file called `_GeneratedTagsPartial.cshtml` will be created in `Views/Shared/`.
Your `Layout.cshtml` should include the following:

```
<head>
  [...]
  @Html.Partial("_HeaderPartial")
</head>
<body>
    @RenderBody()
    [...]
    @Html.Partial("_ScriptsPartial")
</body>
</html>
```



