REPORT your_program

DATA: obj_alv TYPE REF TO cl_salv_table,
       obj_functions TYPE REF TO cl_salv_functions.
       
  DATA: itab TYPE STANDARD TABLE OF table.
  
  SELECT * FROM table INTO TABLE itab.
  
  CALL METHOD: obj_alv=>factory (
   IMPORTING
   r_salv_table = obj_alv
   CHANGING
   t_table = itab.
).
obj_alv->display( ).
