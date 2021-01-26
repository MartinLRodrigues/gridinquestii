using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;

namespace GridInQuestII.Wrapper.CSharp
{
    public static class Extensions
    {
        private static readonly Dictionary<int, string> CoordinateDescriptions;

        static Extensions()
        {
            var members = typeof(CoordinateSystems)
                .GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static)
                .Select(f => new
                {
                    CoordinateDescription = (DescriptionAttribute)f.GetCustomAttributes(typeof(DescriptionAttribute), false).Single(),
                    CoordinateSystem = (int) f.GetRawConstantValue()
                });

            var nodeMembers = members.ToList();
            CoordinateDescriptions = nodeMembers.ToDictionary(f => f.CoordinateSystem, f => f.CoordinateDescription.Description);
        }

        public static string GetDescription(this int coordinateSystemValue)
        {
            return CoordinateDescriptions.ContainsKey(coordinateSystemValue) ? CoordinateDescriptions[coordinateSystemValue] : string.Empty;
        }
    }
}
