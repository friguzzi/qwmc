using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using System.Collections.Generic;

namespace Quantum.MAP
{
    class Driver
    {
        static void Main(string[] args)
        {

            using (var qsim = new QuantumSimulator())
            {
                int n = 1000;
                System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
                string[] results = new string[n];
                for (int i = 0; i < n; i++)
                {
                    IQArray<Result> res = QMAP.Run(qsim).Result;
                    results[i] = res.ToString();
                }
                stopwatch.Stop();
                Console.WriteLine("Elapsed time: " + stopwatch.ElapsedMilliseconds / 1000.0);
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
                string[] split = item.Key.Split(new Char[] { '[', ',', ']' });
                string newkey = "";

                for (int i = 1; i < split.Length - 1; i++)
                {
                    newkey = newkey + (split[i].Equals("One") ? "1" : "0");
                }
                Console.WriteLine("'{0}': {1},", newkey, item.Value);
            }

        }
    }
}