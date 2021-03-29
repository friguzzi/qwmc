using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace Quantum.Sample
{
    class Driver
    {
        static void Main(string[] args)
        {
            using var qsim = new QuantumSimulator();
            int n = 1000;
            System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
            string[] results = new string[n];
            for (int i = 0; i < n; i++)
            {
                var wmc = QWMC.Run(qsim).Result;
                var wmc_rounded = Math.Round(wmc, 3);
                results[i] = wmc_rounded.ToString("0.000", CultureInfo.InvariantCulture);
            }
            stopwatch.Stop();
            Console.WriteLine($"Elapsed time: {stopwatch.ElapsedMilliseconds / 1000.0} sec");
            PrintResults(results);
        }

        static void PrintResults(string[] results)
        {
            IDictionary<string, int> dict = new Dictionary<string, int>();
            for (int i = 0; i < results.Length; i++)
            {
                string s = results[i];
                if (dict.ContainsKey(s))
                    dict[s]++;
                else
                    dict.Add(s, 1);
            }
            foreach (KeyValuePair<string, int> item in dict)
            {
                Console.WriteLine("{0}: {1},", item.Key, item.Value);
            }
            var mostFrequentValue = dict.Aggregate((x, y) => x.Value > y.Value ? x : y).Key;
            Console.WriteLine($"Most frequently found value = {mostFrequentValue}");
        }
    }
}
