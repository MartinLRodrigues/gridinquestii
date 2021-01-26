using System;
using System.Runtime.InteropServices;

namespace GridInQuestII.Wrapper.CSharp
{
    /// <summary>
    /// Set project build platform to 32bit or 64bit depending on the 32/64bit version of GIQ.dll used.
    /// </summary>
    public class Giq
    {
        private const string GiqDll = "GIQ.dll";

        [DllImport(GiqDll)]
        private static extern bool ConvertCoordinates(int SourceSRID, int TargetSRID, int SourceRevision,
            int TargetRevision, ref Coordinates InputCoordinates, ref Coordinates OutputCoordinates, ref int Datum);

        /// <summary>
        /// Transforms coordinates between coordinate systems using Ordnance Survey GridInQuestII library.
        /// Copy GIQ.dll and relevant data files (GM15GB.dat, GM02NI.dat etc.) in bin folder.
        /// </summary>
        /// <param name="sourceSrId">Source coordinate system Id. See <see cref="CoordinateSystems"/></param>
        /// <param name="targetSrId">Target coordinate system Id. See <see cref="CoordinateSystems"/></param>
        /// <param name="sourceRevision">Source coordinate revision number, if any.</param>
        /// <param name="targetRevision">Target coordinate revision number, if any.</param>
        /// <param name="inputCoordinates">Input coordinates. Angles for Geodetic (ETRS89) system need to be in radians. Use <see cref="ConvertToRadians"/> for Degree to Radian conversion.</param>
        /// <param name="datum">The input datum value is ignored for all transformations except those involving source coordinates in ITM or IG. In these cases it must be 13 or 14 for Malin Head or Belfast respectively. The output value only has a meaning for transformations where the target system is IG, ITM, or BNG in which case it is the datum used for the z coordinate. In these cases a return value of 0 means 'Out of Area'</param>
        /// <returns></returns>
        public static Coordinates ConvertCoordinates(int sourceSrId, int targetSrId, int sourceRevision, int targetRevision, Coordinates inputCoordinates, GiqDatums datum)
        {
            Coordinates outputCoordinates = default;
            int datumParam = (int)datum;

            var result = ConvertCoordinates(sourceSrId, targetSrId, sourceRevision, targetRevision, ref inputCoordinates, ref outputCoordinates, ref datumParam);

            if (!result)
            {
                throw new Exception("Failed to find coordinates on target coordinate system. Please check input coordinates and the Datum parameters.");
            }

            return outputCoordinates;
        }

        public static double ConvertToRadians(double angle)
        {
            return angle * Math.PI / 180;
        }
    }
}
