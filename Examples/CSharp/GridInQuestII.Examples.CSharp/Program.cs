using System;
using System.Collections.Generic;
using GridInQuestII.Wrapper.CSharp;

namespace GridInQuestII.Examples.CSharp
{
    class Program
    {
        class InputData
        {
            public int SourceCoordinateSystem { get; set; }
            public int TargetCoordinateSystem { get; set; }
            public int SourceRevision { get; set; }
            public int TargetRevision { get; set; }
            public Coordinates InputCoordinates { get; set; }
            public GiqDatums Datum { get; set; }
            public Coordinates OutputCoordinates { get; set; }
        }

        static void Main(string[] args)
        {
            var inputData = new List<InputData>();
            inputData.Add(new InputData
            {
                SourceCoordinateSystem = CoordinateSystems.SRID_BNG,
                TargetCoordinateSystem = CoordinateSystems.SRID_ETRS89GD,
                Datum = GiqDatums.vdMalinHead,
                InputCoordinates = new Coordinates {X = 507913.94, Y = 208712.39, Z = -46.40 }
            });

            inputData.Add(new InputData
            {
                SourceCoordinateSystem = CoordinateSystems.SRID_ETRS89GD,
                TargetCoordinateSystem = CoordinateSystems.SRID_BNG,
                Datum = GiqDatums.vdMalinHead,
                InputCoordinates = new Coordinates { X = Giq.ConvertToRadians(-0.437565), Y = Giq.ConvertToRadians(51.766707), Z = 0 }
            });

            inputData.Add(new InputData
            {
                SourceCoordinateSystem = CoordinateSystems.SRID_IG,
                TargetCoordinateSystem = CoordinateSystems.SRID_ETRS89GD,
                Datum = GiqDatums.vdMalinHead,
                InputCoordinates = new Coordinates { X = 197633.13413602728, Y = 42463.572674536168, Z = 0 }
            });

            inputData.Add(new InputData
            {
                SourceCoordinateSystem = CoordinateSystems.SRID_ETRS89GD,
                TargetCoordinateSystem = CoordinateSystems.SRID_ITM,
                TargetRevision = 2015,
                Datum = GiqDatums.vdMalinHead,
                InputCoordinates = new Coordinates { X = -0.12217304764, Y = 0.925024503557, Z = 100 }
            });

            Console.WriteLine("Coordinate transformations:");
            inputData.ForEach(input =>
            {
                input.OutputCoordinates = Giq.ConvertCoordinates(input.SourceCoordinateSystem, input.TargetCoordinateSystem,
                    input.SourceRevision, input.TargetRevision, input.InputCoordinates, input.Datum);

                Console.WriteLine($"{input.SourceCoordinateSystem.GetDescription()} => {input.TargetCoordinateSystem.GetDescription()}");
                Console.WriteLine($"\tInput  [X = {input.InputCoordinates.X, -20}, Y = {input.InputCoordinates.Y, -20}, Z = {input.InputCoordinates.Z, -21}]");
                Console.WriteLine($"\tOutput [X = {input.OutputCoordinates.X, -20}, Y = {input.OutputCoordinates.Y, -20}, Z = {input.OutputCoordinates.Z, -21}]");
                Console.WriteLine();
            });

            Console.WriteLine("Press any key ...");
            Console.ReadLine();
        }

    }
}