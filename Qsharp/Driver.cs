using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Collections.Generic;

namespace Quantum.Sample
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var qsim = new QuantumSimulator())
            {
                IDictionary<string, int> dict = new Dictionary<string, int>();
                System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
                for (int i = 0; i < 100; i++)
                {
                    var res = QWMC.Run(qsim).Result;
                    string s = Convert.ToString(res);
                    int result;
                    if (dict.TryGetValue(s, out result))
                    {
                        dict.Remove(s);
                        dict.Add(s, result + 1);
                    }
                    else
                    {

                        dict.Add(s, 1);
                    }
                    System.Console.WriteLine($"Res:{s}");
                }
                stopwatch.Stop();
                Console.WriteLine(stopwatch.ElapsedMilliseconds);
                foreach (KeyValuePair<string, int> item in dict)
                {
                    Console.WriteLine("Key: {0}, Value: {1}", item.Key, item.Value);
                }
            }
        }
    }
}
