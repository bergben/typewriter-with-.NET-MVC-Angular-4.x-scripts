# typewriter-with-.NET-MVC-Angular-4.x-scripts
Scripts to automatically create TypeScript interfaces and Angular 4.x services from .NET MVC backend

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
