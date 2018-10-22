function[rot]=rota(w);
rot=[1 0 0 0;
      0 cos(2*w) -sin(2*w) 0;
      0 sin(2*w)  cos(2*w) 0;
      0 0         0        1];