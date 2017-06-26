${
    // Enable extension methods by adding using Typewriter.Extensions.*
    using Typewriter.Extensions.Types;
    using Typewriter.Extensions.WebApi;
    using System.Text.RegularExpressions;
    
    // File Naming CamelCase to dash-case
    Template(Settings settings)
    {   
        /* Create dash-cased file name according to Angular Style Guide */
        settings.OutputFilenameFactory = file => 
        {
            string FileName=file.Name.Replace(".cs", ".ts").Replace("ApiController",".service").Replace("Controller",".service");
            FileName= ToDashCase(FileName);
            return $"{FileName}";
        };
    }
    /* CamelCase to dash-case */
    string ToDashCase(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
           return "";
        System.Text.StringBuilder newText = new System.Text.StringBuilder(text.Length * 2);
        newText.Append(char.ToLower(text[0]));
        for (int i = 1; i < text.Length; i++)
        {
            if (char.IsUpper(text[i]) && text[i-1] != '-')
                newText.Append('-');
            newText.Append(char.ToLower(text[i]));
        }
        return newText.ToString();
    }
    
   bool HasAttributeResponseType(Method m)
   {
       return m.Attributes.Any(a=> String.Equals(a.Name, "ResponseType", StringComparison.OrdinalIgnoreCase));
   }
   string ResponseType(Method m){
        string responseTypeValue=m.Attributes.FirstOrDefault(a => String.Equals(a.Name, "ResponseType", StringComparison.OrdinalIgnoreCase)).Value;
        return ResponseTypeValueCleanup(responseTypeValue);
   }
   string ResponseTypeValueCleanup(string responseTypeValue){
        // remove typeof(...), keep ...
        responseTypeValue = responseTypeValue.Substring(responseTypeValue.IndexOf('(')+1);
        responseTypeValue = responseTypeValue.TrimEnd(')');

        // for x.y.z, return just z
        var index = responseTypeValue.LastIndexOf('.');
        if (index != -1) {
            responseTypeValue = responseTypeValue.Substring(index + 1);
        }
        if(responseTypeValue.Contains("bool")){
            responseTypeValue=responseTypeValue.Replace("bool", "boolean");
        }
        if(responseTypeValue.Contains("int") || responseTypeValue.Contains("float") || responseTypeValue.Contains("double")){
            responseTypeValue=responseTypeValue.Replace("int", "number").Replace("float", "number").Replace("double", "number");
        }
        return responseTypeValue.Replace("ViewModel","");
   }

    // Custom extension methods can be used in the template by adding a $ prefix
    string RenameControllerToService(string name) => name.Replace("Controller", "Service");
    string ServiceName(Class c) => RenameControllerToService(c.Name);

    IEnumerable<Method> getClassMethods(Class c){
        return c.Methods.Where(m=> m.Attributes.Any(a=> String.Equals(a.Name, "ResponseType", StringComparison.OrdinalIgnoreCase)));
    }
    string ImportParams(Class c)
    {
        IEnumerable<Method> methods = getClassMethods(c);

        var allTypes = methods
            .SelectMany(m => m.Parameters.Select(p => p.Type).Concat(new [] { m.Type }))
            .Select(t => CalculatedType(t))
            .Where(t => t != null && (t.IsDefined || (t.IsEnumerable && !t.IsPrimitive)));
            
        string importParamsString=string.Join(Environment.NewLine, allTypes.Select(t => $"import {{ {ReplaceViewModel(t.ClassName())} }} from '../models/models';").Distinct());
        return importParamsString;
    }
    
   string ImportResponseTypes(Class c)
   {
        IEnumerable<Method> methods = getClassMethods(c);
        IEnumerable<string> responseTypesList= methods.Select(s=>
            ResponseTypeValueCleanup(s.Attributes.FirstOrDefault(a=> String.Equals(a.Name, "ResponseType", StringComparison.OrdinalIgnoreCase)).Value))
        .Distinct().Where(t=> !ResponseTypeIsPrimitive(ResponseTypeValueCleanup(t)));
        
        string importResponseTypesString=string.Join(Environment.NewLine, responseTypesList.Select(t => $"import {{ {ReplaceViewModel(t).Replace("[]","")} }} from '../models/models';"));
        return importResponseTypesString ;
    }

    Type CalculatedType(Type t)
    {
        var type = t;
        while (!type.IsEnumerable && type.IsGeneric) {
            type = type.Unwrap();
        }
        return type.Name == "IHttpActionResult" ? null : type;
    }

    bool ResponseTypeIsPrimitive(string t){
        return t==null || t.Contains("boolean") || t.Contains("string") || t.Contains("number") || t=="void" || t.Contains("any") || t.Contains("enum") || t.Contains("Date");
    }
    string CalculatedTypeName(Type t)
    {
        var type = CalculatedType(t);
        return type != null ? type.Name : "void";
    }
    string UrlTrimmed(Method m){
        string url=m.Url().TrimEnd('/');
        var parameters=m.Parameters.Where(p=> p.Type.IsEnumerable);
        parameters.ToList().ForEach(parameter => {
                url=url.Replace("&"+parameter.name+"=${"+parameter.name+"}","");
        });

        return url;
    }
    string URLArrays(Method m){
        string arrayCode="";
        var parameters=m.Parameters.Where(p=> p.Type.IsEnumerable);
        parameters.ToList().ForEach(parameter=>{
            arrayCode+=parameter.name+".forEach(value => { url+='&"+parameter.name+"='+value});";
        });
        return arrayCode;
    }
    string ParameterType(Parameter p){
        string type=p.Type.ToString();
        if(type=="bool"){
            type="boolean";
        }
        if(type=="Date"){
            type="Date | string";
        }
        return ReplaceViewModel(type);
    } 
    string ReplaceViewModel(string s) => s.Replace("ViewModel","");
}
//*************************DO NOT MODIFY**************************
//
//THESE FILES ARE AUTOGENERATED WITH TYPEWRITER AND ANY MODIFICATIONS MADE HERE WILL BE LOST
//PLEASE VISIT http://frhagn.github.io/Typewriter/ TO LEARN MORE ABOUT THIS VISUAL STUDIO EXTENSION
//
//*************************DO NOT MODIFY**************************

import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions, Request } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import { environment } from '../../environments/environment';

$Classes(c => c.Attributes.Any(a => a.Name == "TSGenerate"))[
$ImportParams
$ImportResponseTypes

@Injectable()
export class $ServiceName {
    constructor(private http: Http) { }
    
    $Methods(m => HasAttributeResponseType(m) && ResponseType(m) == "void")[
    public $name = ($Parameters[$name: $ParameterType][, ]) : Observable<Response> => {
        let headers = new Headers({ 'Content-Type':  'application/json; charset=utf-8' });
        let options:RequestOptions=new RequestOptions({ headers: headers });
        let url=environment.apiBaseUrl + `$UrlTrimmed`;
        $URLArrays
        let request=new Request(options.merge({
            withCredentials: true,
            method: '$HttpMethod',
            body: JSON.stringify($RequestData),
            url: url
        }));
        return this.http.request(request);
    }]
    $Methods(m => HasAttributeResponseType(m) && ResponseType(m) != "void" && !ResponseTypeIsPrimitive(ResponseType(m)))[
    public $name = ($Parameters[$name: $ParameterType][, ]) : Observable<$ResponseType> => {
        let headers = new Headers({ 'Content-Type':  'application/json; charset=utf-8' });
        let options:RequestOptions=new RequestOptions({ headers: headers });
        let url=environment.apiBaseUrl + `$UrlTrimmed`;
        $URLArrays
        let request=new Request(options.merge({
            withCredentials: true,
            method: '$HttpMethod',
            body: JSON.stringify($RequestData),
            url: url
        }));
        return this.http.request(request).map(res => 
            (<$ResponseType>this.propertiesToLowerCase(res.json()))
        );
    }]
    $Methods(m => HasAttributeResponseType(m) && ResponseType(m) != "void" && ResponseTypeIsPrimitive(ResponseType(m)))[
    public $name = ($Parameters[$name: $ParameterType][, ]) : Observable<$ResponseType> => {
        let headers = new Headers({ 'Content-Type':  'application/json; charset=utf-8' });
        let options:RequestOptions=new RequestOptions({ headers: headers });
        let url=environment.apiBaseUrl + `$UrlTrimmed`;
        $URLArrays
        let request=new Request(options.merge({
            withCredentials: true,
            method: '$HttpMethod',
            body: JSON.stringify($RequestData),
            url: url
        }));
        return this.http.request(request).map(res => 
            (<$ResponseType>this.propertiesToLowerCase(res.json()))
        );
    }]

    private propertiesToLowerCase(object: any):any{
        if(!object || object===null){
            return object;
        }
        let keys=Object.keys(object);
        if(!keys || !keys.length || keys.length===0){
            return object;
        }
        keys.forEach(curKey =>{
            let lowerCaseKey = isNaN(parseInt(curKey)) ? curKey[0].toLowerCase()+curKey.substring(1) : parseInt(curKey);
            let newValue = typeof object[curKey] === 'object' ? this.propertiesToLowerCase(object[curKey]) : object[curKey];
            object[lowerCaseKey] = newValue;
            if(isNaN(parseInt(curKey)) && lowerCaseKey !== curKey ){
                delete object[curKey];
            }
        });
        return object;
    }
}]