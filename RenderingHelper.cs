using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.UI;

namespace WebApp.Helper
{
    public class FakeController : Controller
    {
    }

    public static class RenderingHelper
    {
        public static string RenderScriptTagsFromPartial(string viewName)
        {
            string partialContent = RenderPartialToString(viewName);

            /* The following pattern will match any script tags: <script [...]></script> */
            string pattern = "<script.+?</script>";

            string result = GetRegexMatchedTags(partialContent, pattern);

            return result;
        }


        public static string RenderStyleTagsFromPartial(string viewName)
        {
            string partialContent = RenderPartialToString(viewName);

            /* The following pattern will match any link tags: <link [...]/> */
            string pattern = "<link.+?/>";

            string result = GetRegexMatchedTags(partialContent, pattern);

            return result;
        }

        private static string GetRegexMatchedTags(string content, string pattern)
        {
            MatchCollection matchList = Regex.Matches(content, pattern);
            List<string> tagsList = matchList.Cast<Match>().Select(match => match.Value).ToList();

            string tags = string.Join(Environment.NewLine, tagsList);

            return tags;
        }


        public static string RenderPartialToString(string viewName)
        {
            var st = new StringWriter();
            var context = new HttpContextWrapper(HttpContext.Current);
            var routeData = new RouteData();
            var controllerContext = new ControllerContext(new RequestContext(context, routeData), new FakeController());
            var razor = new RazorView(controllerContext, viewName, null, false, null);
            razor.Render(new ViewContext(controllerContext, razor, new ViewDataDictionary(new { }), new TempDataDictionary(), st), st);
            return st.ToString();
        }

    }
}