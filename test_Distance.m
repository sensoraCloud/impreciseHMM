
C=1;
N=4;
F=1;
M=3;
T=50;

%precision
eps=0.9;

if C==0
    
    [ iPi0,iA0,iB0 ] = impreciseHmmGenerator( N,C,F,eps,M );

    [ iPi,iA,iB ] = impreciseHmmGenerator( N,C,F,eps,M );

    %generate HMM from pignistic
    
    [ pPi0, pA0, pB0 ] = pignisticHMM( iPi0,iA0,iB0 );
    
    %generate pignistic observation
    [ betO ] = sequenceGenerator( pPi0,pA0,T,pB0 );
    
    %transform mono-feature iHMM1 discretizing iHMM1 on betO
    if (F>1)
        [ iB0 O ] = discretizediImpreciseHmm( iPi0,iA0,betO,iB0 );        
        %discretized iHMM2 on betO (for transform iB (1..M) to iB (1..T) )
        [ iB O ] = discretizediImpreciseHmm( iPi,iA,betO,iB );
    end

    
else
    
    [ iPi0,iA0,iMu0,iSigma0 ] = impreciseHmmGenerator( N,C,F,eps );

    [ iPi,iA,iMu,iSigma ] = impreciseHmmGenerator( N,C,F,eps );

    %generate HMM from pignistic
    [ pPi0, pA0, pMu0,pSigma0 ] = pignisticHMM( iPi0,iA0,iMu0,iSigma0 );
    
    [ betO ] = sequenceGenerator( pPi0,pA0,T,pMu0,pSigma0 );
    
    % transform continuos multi-features iHMM to discrete mono-feature iHMM
    [ iB0 O ] = discretizediImpreciseHmm( iPi0,iA0,betO,iMu0,iSigma0 );
    
    %discretized iHMM2 on betO
    [ iB O ] = discretizediImpreciseHmm( iPi,iA,betO,iMu,iSigma );
    
end

%generete input file for Denis algorithm
generateFileModelData( iPi0,iA0,O,'mod0',iB0 );
generateFileModelData( iPi,iA,O,'mod',iB );

[ delta_lower delta_upper ] = imprecise_distance( iPi0,iA0,iPi,iA,O,'mod0.model','mod0.data','mod.model','mod.data',iB0,iB );
