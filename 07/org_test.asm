    name org_test          ; module name

    include "inc\arcadia.h"      ; v1.01

    org         0000H        ; Start of Arcadia ROM

    lodi,r0 0AAh

    org         1000h

    lodi,r0 0BBh

    org         2000h

    lodi,r0 0CCh

end ; End of assembly
