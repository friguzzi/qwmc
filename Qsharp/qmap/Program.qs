﻿namespace Quantum.MAP {


    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;


	operation Sprinkler(q : Qubit[],  target : Qubit) : Unit is Adj+Ctl 
	{
		use a = Qubit[3];
        within {
		    X(q[2]);
		    X(a[0]);
		    X(a[1]);
		    X(a[2]);
		    CCNOT(q[0], q[1], a[0]);
		    CCNOT(q[1], q[2], a[1]);
		    CCNOT(q[0], q[2], a[2]);
        } apply {
    		Controlled X(a + [q[3]], target);
        }
	}
    
	operation ApplyMarkingOracleAsPhaseOracle(markingOracle : ((Qubit[], Qubit) => Unit is Adj+Ctl),  q : Qubit[]) :  Unit is Adj+Ctl 
	{   
        use target = Qubit();
        within {
            // Put the target into the |-⟩ state
            X(target);
            H(target);
        } apply {
            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            markingOracle(q, target);
        }
	}

    
    // The Grover iteration
    operation GroverIteration(q : Qubit[], oracle : ((Qubit[],Qubit) => Unit is Adj+Ctl), weights : Double[]) : Unit is Ctl+Adj
	{
        ApplyMarkingOracleAsPhaseOracle(oracle, q);
        within {
            Adjoint Rot(q, weights);
            ApplyToEachCA(X, q);    // Brings |0..0⟩ to |1..1⟩
        } apply {
            use a = Qubit();
    	    Controlled X(q, a);     // Bit flips the a to |1⟩ if register is |1...1⟩ 
            Z(a);                   // The phase of a (and therefore the whole register phase) becomes -1 if above condition is satisfied
    	    Controlled X(q, a);     // Puts a back in |0⟩ 
            Ry(2.0 * PI(), q[0]);
        }
    }    

    operation Rot(q: Qubit[], weights : Double[]): Unit is Ctl+Adj 
    {
        // Prepare the eigenstate of U
        for i in 0 .. Length(weights) - 1 {
            let theta = 2.0 * ArcSin(Sqrt(weights[i]));
            Ry(theta, q[i]);
        }
        H(q[3]);
	}


    operation QMAP() : Result[] 
    {
        let weights = [0.55, 0.3, 0.7];
        
        use reg = Qubit[4];
        Rot(reg, weights);
        GroverIteration(reg, Sprinkler, weights);
        let query = Subarray([0, 2],reg);
        let state = MultiM(query);

        ResetAll(reg);
        return state;
    }
}

