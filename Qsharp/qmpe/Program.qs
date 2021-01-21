namespace Quantum.MPE {


    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;


	operation Sprinkler (queryRegister:  Qubit[],  target : Qubit) : Unit is Adj+Ctl 
	{
		using (ancilla=Qubit[3])
		{
			X(queryRegister[2]);
			X(ancilla[0]);
			X(ancilla[1]);
			X(ancilla[2]);
		
			CCNOT(queryRegister[0],queryRegister[1],ancilla[0]);
			CCNOT(queryRegister[1],queryRegister[2],ancilla[1]);
			CCNOT(queryRegister[0],queryRegister[2],ancilla[2]);
			(Controlled X)([ancilla[0],ancilla[1],ancilla[2],queryRegister[3]],target);
			CCNOT(queryRegister[0],queryRegister[2],ancilla[2]);
			CCNOT(queryRegister[1],queryRegister[2],ancilla[1]);
			CCNOT(queryRegister[0],queryRegister[1],ancilla[0]);

			X(ancilla[2]);
			X(ancilla[1]);
			X(ancilla[0]);
			X(queryRegister[2]);

		}
	}
	
	operation ApplyMarkingOracleAsPhaseOracle (markingOracle : ((Qubit[], Qubit) => Unit is Adj+Ctl),  register : Qubit[] ) :  Unit is Adj+Ctl 
	{
        
        using (target = Qubit()) 
		{
            // Put the target into the |-⟩ state
            X(target);
            H(target);
                
            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            markingOracle(register, target);
                
            // Put the target back into |0⟩ so we can return it
            H(target);
            X(target);
        }
	}

    
    // The Grover iteration
    operation GroverIteration (register : Qubit[], oracle : ((Qubit[],Qubit) => Unit is Adj+Ctl)) : Unit is Ctl+Adj
	{
        ApplyMarkingOracleAsPhaseOracle(oracle,register);
        Adjoint PrepareEigenState(register);
        ApplyToEachCA(X, register);
        using (ancilla = Qubit()){
    	    (Controlled X)([register[0],register[1],register[2],register[3]],ancilla);
            Z(ancilla);
    		(Controlled X)([register[0],register[1],register[2],register[3]],ancilla);
}
        ApplyToEachCA(X, register);
        Ry(2.0 * PI(), register[0]);
        PrepareEigenState(register);
    }    

    operation PrepareEigenState(q: Qubit[]): Unit is Ctl+Adj 
    {
        // Prepare the eigenstate of U
        let theta0=2.0*ArcSin(Sqrt(0.55));
	    let theta1=2.0*ArcSin(Sqrt(0.3));
	    let theta2=2.0*ArcSin(Sqrt(0.7));
	    Ry(theta0,q[0]);
	    Ry(theta1,q[1]);
	    Ry(theta2,q[2]);
        H(q[3]);
	}
	operation QMPE() : Result[] 
	{
        
		using (reg=Qubit[4])
		{
			let oracle = OracleToDiscrete(GroverIteration(_,Sprinkler(_,_)));
		
            PrepareEigenState(reg);
            for (i in 1 .. 1) {
                GroverIteration(reg, Sprinkler);
            }
		    let query= Subarray([0,1,2],reg);
            let state = MultiM(query);

            ResetAll(reg);
            return state;
        }
    }
}

