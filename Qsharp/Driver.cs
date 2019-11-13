using System;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quantum.Sample
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var qsim = new QuantumSimulator())
            {
		var tot=0.0;
                for (int i = 0; i < 10; i++)
                {
                    var res = QWMC.Run(qsim).Result;
		    tot = tot+res;
                    System.Console.WriteLine($"Res:{res}");
                }
		var av=tot/10.0;
                System.Console.WriteLine($"Av:{av}");
            }
        }
    }
}
