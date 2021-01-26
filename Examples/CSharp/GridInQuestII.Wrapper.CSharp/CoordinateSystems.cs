using System.ComponentModel;

namespace GridInQuestII.Wrapper.CSharp
{
    public class CoordinateSystems
    {
        /// <summary>
        /// ETRS89 Cartesian
        /// </summary>
        [Description("ETRS89 Cartesian")]
        public const int SRID_ETRS89CT = 4936;
        /// <summary>
        /// ETRS89 Geodetic
        /// </summary>
        [Description("ETRS89 Geodetic")]
        public const int SRID_ETRS89GD = 4937;
        /// <summary>
        /// ETRS89/UTM Zone 29N
        /// </summary>
        [Description("ETRS89/UTM Zone 29N")]
        public const int SRID_UTM29N = 25829;
        /// <summary>
        /// ETRS89/UTM Zone 30N
        /// </summary>
        [Description("ETRS89/UTM Zone 30N")]
        public const int SRID_UTM30N = 25830;
        /// <summary>
        /// ETRS89/UTM Zone 31N
        /// </summary>
        [Description("ETRS89/UTM Zone 31N")]
        public const int SRID_UTM31N = 25831;
        /// <summary>
        /// OSBG36/British National Grid (TN15/GM15)
        /// </summary>
        [Description("OSBG36/British National Grid (TN15/GM15)")]
        public const int SRID_BNG = 27700;
        /// <summary>
        /// Irish Grid (IG/GM15)
        /// </summary>
        [Description("Irish Grid (IG/GM15)")]
        public const int SRID_IG = 29903;
        /// <summary>
        /// Irish Transverse Mercator (ITM/GM15)
        /// </summary>
        [Description("Irish Transverse Mercator (ITM/GM15)")]
        public const int SRID_ITM = 2157;
    }
}
