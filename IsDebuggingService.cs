using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;

namespace WebApp.Helper
{
    public class IsDebuggingService
    {
        private static bool debugging;

        public static bool RunningInDebugMode()
        {
            #if DEBUG
                return true;
            #else
                return false;
            #endif
            WellAreWe();
            return debugging;
        }

        [Conditional("DEBUG")]
        private static void WellAreWe()
        {
            debugging = true;
        }
    }
}