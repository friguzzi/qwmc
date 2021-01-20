using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Collections.Generic;
using System.Globalization;
namespace Quantum.Sample
{
    class Driver
    {
        static void Main(string[] args)
        {
            using (var qsim = new QuantumSimulator())
            {
                int n = 100;
                System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
                string[] results = new string[n];
                for (int i = 0; i < n; i++)
                {
                    var wmc = QWMC.Run(qsim).Result;
                    var wmc_rounded = Math.Round(wmc, 3);
                    results[i] = wmc_rounded.ToString("0.000", CultureInfo.InvariantCulture);
                }
                stopwatch.Stop();
                Console.WriteLine(stopwatch.ElapsedMilliseconds / 1000.0);
                PrintResults(results);
            }
        }

        static void PrintResults(string[] results)
        {
            IDictionary<string, int> dict = new Dictionary<string, int>();
            int result;
            for (int i = 0; i < results.Length; i++)
            {
                string s = results[i];
                if (dict.TryGetValue(s, out result))
                {
                    dict.Remove(s);
                    dict.Add(s, result + 1);
                }
                else
                    dict.Add(s, 1);
            }
            foreach (KeyValuePair<string, int> item in dict)
            {
                Console.WriteLine("{0}: {1},", item.Key, item.Value);
            }
        }
    }
}
