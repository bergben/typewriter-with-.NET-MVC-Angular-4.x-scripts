﻿${
   // Enable extension methods by adding using Typewriter.Extensions.*
   using Typewriter.Extensions.Types;
 
    // File Naming CamelCase to dash-case
    Template(Settings settings)
    {
        settings.OutputFilenameFactory = file => 
        {
            string FileName=file.Name.Replace(".cs", "").Replace("ViewModels","").Replace("ViewModel","")+".model.ts";
            FileName= ToDashCase(FileName);
            return $"{FileName}";
        };
    }

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
    
    static IEnumerable<string> allClassNamesInFile;
    static IEnumerable<string> allEnumNamesInFile;

    void GetClassNames(File f){
        IEnumerable<Class> classes = f.Classes;
        allClassNamesInFile = classes.Select(t=> t.Name).Distinct();
    }

    void GetEnumNames(File f){
        IEnumerable<Enum> enums = f.Enums;
        allEnumNamesInFile = enums.Select(t=> t.Name).Distinct();
    }

    string ImportProperties(Class c)
    {
        IEnumerable<Property> properties = c.Properties;
        properties=properties.Where(p=> (!allClassNamesInFile.Any(name => String.Equals(p.Type.Name, name)) && !allEnumNamesInFile.Any(name => String.Equals(p.Type.Name, name))));
        var allTypes = properties
            .Select(t => CalculatedType(t.Type))
            .Where(t => t != null && (t.IsDefined || (t.IsEnumerable && !t.IsPrimitive)));
            
        string importPropertiesString=string.Join(Environment.NewLine, allTypes.Select(t => $"import {{ {ReplaceViewModel(t.ClassName())} }} from '../models/models';").Distinct());
        return importPropertiesString;
    }
    
    Type CalculatedType(Type t)
    {
        var type = t;
        while (!type.IsEnumerable && type.IsGeneric) {
            type = type.Unwrap();
        }
        return type.Name == "IHttpActionResult" ? null : type;
    }
    
    string PropertyName(Property p) => Char.ToLowerInvariant(p.Name[0])+p.Name.Substring(1);
    string ClassName(Class c) => c.Name.Replace("ViewModel", "");
    string PropertyType(Property p){
        string type=p.Type.ToString();
        if(type=="bool"){
            type="boolean";
        }
        return ReplaceViewModel(type);
    } 
    string ReplaceViewModel(string s) => s.Replace("ViewModel","");
}

${
   //The do not modify block below is intended for the outputed typescript files... 
}

//*************************DO NOT MODIFY**************************
//
//THESE FILES ARE AUTOGENERATED WITH TYPEWRITER AND ANY MODIFICATIONS MADE HERE WILL BE LOST
//PLEASE VISIT http://frhagn.github.io/Typewriter/ TO LEARN MORE ABOUT THIS VISUAL STUDIO EXTENSION
//
//*************************DO NOT MODIFY**************************
$GetClassNames $GetEnumNames

$Classes(*ViewModel)[
$ImportProperties

/* Interface for: $FullName */
export interface $ClassName$TypeParameters $BaseClass[extends $ClassName$TypeArguments]{
    $Properties[ 
    $PropertyName: $PropertyType;]
}
]
$Enums(*)[
export enum $Name {$Values[ 
    $Name = $Value,]
}]