namespace Quantum.Sample
{
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Arrays;


	operation SprinklerAnc (queryRegister:  Qubit[],  target : Qubit) : Unit is Adj+Ctl 
	{
		using (ancilla=Qubit[3 ])
		{
			X(queryRegister[2]);
			X(ancilla[0]);
			X(ancilla[1]);
			X(ancilla[2]);
		
			CCNOT(queryRegister[0],queryRegister[1],ancilla[0]);
			CCNOT(queryRegister[1],queryRegister[2],ancilla[1]);
			CCNOT(queryRegister[0],queryRegister[2],ancilla[2]);
			(Controlled X)([ancilla[1],ancilla[2]],target);
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
        ApplyToEachCA(H, register);
        ApplyToEachCA(X, register);
        Controlled Z(Most(register), Tail(register));
        ApplyToEachCA(X, register);
        R(PauliI, 2.0 * PI(), register[0]);
        ApplyToEachCA(H, register);
    }    


	operation QWMC() : Double 
	{
        mutable phase = -1.0;
		let n=5;
		using ((reg,phaseRegister)=(Qubit[3 ], Qubit[n]))
		{
			let oracle = OracleToDiscrete(GroverIteration(_,SprinklerAnc(_,_)));
			// Allocate qubits to hold the eigenstate of U and the phase in a big endian register 
            
            let phaseRegisterBE = BigEndian(phaseRegister);
            // Prepare the eigenstate of U
			let theta0=2.0*ArcCos(Sqrt(0.3));
			let theta1=2.0*ArcCos(Sqrt(0.2));
			let theta2=2.0*ArcCos(Sqrt(0.5));
			Ry(theta0,reg[0]);
			Ry(theta1,reg[1]);
			Ry(theta2,reg[2]);
            // Call library
            QuantumPhaseEstimation(oracle, reg, phaseRegisterBE);
            // Read out the phase
            set phase = IntAsDouble(MeasureInteger(BigEndianAsLittleEndian(phaseRegisterBE))) / IntAsDouble(1 <<< (n));

            ResetAll(reg);
            ResetAll(phaseRegister);
        }
		let angle = PI()*phase;
        let res = (PowD(Sin(angle),2.0));

        return res;
    }
}
