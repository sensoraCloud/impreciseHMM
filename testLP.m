%N=2   i vincoli vanno tutti scritti come A x <= b
% N=2
%Esempio probabilit� stazionarie: [ 0.2  0.6; 0.4 0.8]
% A = [1 0  ; %p1<=u1
%      -1 0  ; %-p1<=-l1
%      0 1  ;
%      0 -1  ;
%      -1 -1 ; %-p1 - p2 <=-1
%      1 1 ; %p1 + p2 <=1
%      -1 0  ; %-p1<=0
%      0 -1 ];
%  b=[0.6 -0.2 0.8 -0.4 -1 1 0 0 ]';
% [V,nr]=con2vert(A,b);
% disp(nr);%vincoli che ritiene non ridondanti
% disp(V);
% sum(V,2)




% 
% %una variabile in meno
% A = [ 1 ; % p1<=u1
%      -1 ; %-p1<=-l1
%      -1 ; %-p1<=u2-1
%       1 ; %p1<=-l2+1
%        %-p1>=0
%        ]; %pi<=1
%  b=[0.6 -0.2 (0.8-1) (-0.4+1)]';
% [V,nr]=con2vert(A,b);
% disp(nr);%vincoli che ritiene non ridondanti
% disp(V);
% sum(V,2)

%vertex = get_imprecise_simplex_vertex( [0.2 0.4],[0.6 0.8] )


%!! solo alcuni vertici rispettano il vincolo p1+p2+p3=1 , penso si aun
%problema della classe con2vert come scritto nel punto 4:
%         4) This program requires that the feasible region have some
%            finite extent in all dimensions. For example, the feasible
%            region cannot be a line segment in 2-D space, or a plane
%            in 3-D space.

%!! infatti se visualizziamo la soluzione ad esempio quando N=2 lui si accorge che i vertici che le
%soluzioni corrette (rosso) stanno sulla retta 



%per N=3 ho 3 intervalli di probabilit�.
%Esempio: [ 0.2  0.6; 0.1  0.7; 0.3  0.5]
%Esempio: 
%[ 0  1; 0  1; 0  1]

%N=3
% % A = [1 0 0 ; %p1<=u1
%      -1 0 0 ; %-p1<=-l1
%      0 1 0 ;
%      0 -1 0 ;
%      0 0 1 ;
%      0 0 -1 ;
%      -1 -1 -1; %-p1 - p2 - p3<=-1
%      1 1 1; %p1 + p2 + p3<=1
%      -1 0 0 ; %-p1<=0
%      0 -1 0 ;
%      0 0 -1 ];
%  b=[0.6 -0.2 0.7 -0.1 0.5 -0.3 -1 1 0 0 0 ]';
% [V,nr]=con2vert(A,b);
% disp(V);
% sum(V,2)


% Esempio: [ 0.2  0.6; 0.1  0.7; 0.3  0.5]
% una variabile in meno
A = [ 1 0; % p1<=u1
     -1 0; %-p1<=-l1
     0 1; % p2<=u2
     0 -1; %-p2<=-l2
     -1 -1; %-p1-p2<=u3-1
      1 1 %p1+p2<=-l3+1
        ];
b=[.6 -.2 .7 -.1 (.5-1) (-.3+1)]';
[V,nr]=con2vert(A,b);
disp(nr);%vincoli che ritiene non ridondanti
disp(V);
sum(V,2)
[V ones(size(V,1),1)-sum(V,2)]


vertex = get_imprecise_simplex_vertex( [0.2 0.1 0.3 ],[0.6 0.7 0.5] )

% 
% figure('renderer','zbuffer')
% hold on
% [x,y]=ndgrid(-1:.01:1);
% p=[x(:) y(:)]';
% p=(A*p <= repmat(b,[1 length(p)]));
% p = double(all(p));
% p=reshape(p,size(x));
% h=pcolor(x,y,p);
% set(h,'edgecolor','none')
% set(h,'zdata',get(h,'zdata')-1) % keep in back
% axis equal
% plot(V(:,1),V(:,2),'y.')


% N=4   [ 0.2965    0.3965; 0.1860    0.2860 ;  0.0678    0.1678; 4 0.3497    0.4497]
% A = [1 0 0 0;
%      -1 0 0 0;
%      0 1 0 0;
%      0 -1 0 0;
%      0 0 1 0;
%      0 0 -1 0;
%      0 0 0 1;
%      0 0 0 -1;
%      -1 -1 -1 -1;
%      1 1 1 1;
%      -1 0 0 0;
%      0 -1 0 0;
%      0 0 -1 0
%      0 0 0 -1];
%  b=[0.3965 -0.2965 0.2860 -0.1860 0.1678 -0.0678  0.4497 -0.3497 -1 1 0 0 0 0 ]';
% 
% V=con2vert(A,b);
% disp(V);
% sum(V,2)
% 
% % % N=4   [ 0.2965    0.3965; 0.1860    0.2860 ;  0.0678    0.1678 ; 0.3497    0.4497]
% A = [1  0  0;
%     -1  0  0;
%      0  1  0;
%      0 -1  0;
%      0  0  1;
%      0  0 -1;
%      -1 -1 -1;
%       1  1  1
%      ];
% b=[0.3965 -0.2965 0.2860 -0.1860 0.1678 -0.0678  (0.4497-1) (-0.3497+1) ]';
% 
% V=con2vert(A,b);
% disp(nr);%vincoli che ritiene non ridondanti
% disp(V);
% [V ones(size(V,1),1)-sum(V,2)]
% 
% vertex = get_imprecise_simplex_vertex( [0.2965 0.1860 0.0678 0.3497 ],[0.3965 0.2860 0.1678  0.4497 ] )


