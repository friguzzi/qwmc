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


	operation Sprinkler (q:  Qubit[],  target : Qubit) : Unit is Adj+Ctl 
	{
		using (a=Qubit[3 ])
		{
			X(q[2]);
			X(a[0]);
			X(a[1]);
			X(a[2]);
		
			CCNOT(q[0],q[1],a[0]);
			CCNOT(q[1],q[2],a[1]);
			CCNOT(q[0],q[2],a[2]);
			(Controlled X)([a[0],a[1],a[2],q[3]],target);
			CCNOT(q[0],q[2],a[2]);
			CCNOT(q[1],q[2],a[1]);
			CCNOT(q[0],q[1],a[0]);

			X(a[2]);
			X(a[1]);
			X(a[0]);
			X(q[2]);
		}
	}
	
	operation ApplyMarkingOracleAsPhaseOracle (markingOracle : ((Qubit[], Qubit) => Unit is Adj+Ctl),  q : Qubit[] ) :  Unit is Adj+Ctl 
	{   
        using (target = Qubit()) 
		{
            // Put the target into the |-⟩ state
            X(target);
            H(target);
                
            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            markingOracle(q, target);
                
            // Put the target back into |0⟩ so we can return it
            H(target);
            X(target);
        }
	}

    
    // The Grover iteration
    operation GroverIteration(q : Qubit[], oracle : ((Qubit[],Qubit) => Unit is Adj+Ctl)) : Unit is Ctl+Adj
	{
        
        ApplyMarkingOracleAsPhaseOracle(oracle,q);
        Adjoint Rot(q);
        ApplyToEachCA(X, q); // brings |0..0> to |1..1>
        using (a = Qubit()){
    		(Controlled X)([q[0],q[1],q[2],q[3]],a);  // Bit flips the a to |1⟩ if register is |1...1⟩ 
            Z(a);  // a phase (and therefore whole register phase) becomes -1 if above condition is satisfied
    		(Controlled X)([q[0],q[1],q[2],q[3]],a);  // Puts a back in |0⟩ 
        }
        ApplyToEachCA(X, q);
        Ry(2.0 * PI(), q[0]);
        Rot(q);
    }    

    operation Rot(q: Qubit[]): Unit is Ctl+Adj 
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

	operation QWMC() : Double 
	{
		let n=7;
		using ((q,p)=(Qubit[4], Qubit[n]))
		{
			let oracle = OracleToDiscrete(GroverIteration(_,Sprinkler(_,_)));
            Rot(q);
			// Allocate qubits to hold the eigenstate of U and the phase in a big endian register 
            let pBE = BigEndian(p);
            // Call library
            QuantumPhaseEstimation(oracle, q, pBE);
            // Read out the phase
            let phase = IntAsDouble(MeasureInteger(BigEndianAsLittleEndian(pBE))) / IntAsDouble(1 <<< (n));

            ResetAll(q);
            ResetAll(p);
            // the phase returned by QuantumPhaseEstimation is the value phi such that
            // e^{2pi phi} is an eigenvalue
		    let angle = 2.0*PI()*phase; 
            let wmc = 2.0*PowD(Sin(angle/2.0),2.0);
            // the 2.0 factor is added because there is an extra bit with weight 0.5
            // that is introduced to make the weighted count < 0.5

            return wmc;
        }
    }
}
