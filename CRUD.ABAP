TABLES: zprodutos_201.
DATA: codprod TYPE zprodutos_201-produto.


DATA: it_produto TYPE STANDARD TABLE OF zprodutos_201,
      wa_produto LIKE LINE OF it_produto.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:  delete RADIOBUTTON GROUP g1 USER-COMMAND test DEFAULT 'X',
            create RADIOBUTTON GROUP g1,
            read   RADIOBUTTON GROUP g1,
            update RADIOBUTTON GROUP g1.

SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-001.
*SELECTION-SCREEN BEGIN OF SCREEN 2000.
PARAMETERS:
  codprod1 TYPE zprodutos_201-produto,
  desc     TYPE zprodutos_201-desc_produto DEFAULT '',
  preco    TYPE zprodutos_201-preco,
  moeda    TYPE zprodutos_201-moeda DEFAULT 'BRL',
  tipoprod TYPE zprodutos_201-tipoproduto.
*SELECTION-SCREEN END OF SCREEN 2000.
SELECTION-SCREEN END OF BLOCK B2.



*SELECTION-SCREEN BEGIN OF SCREEN 3000.
*PARAMETERS:codprod1 TYPE zprodutos_201-produto.
*SELECTION-SCREEN END OF SCREEN 3000.
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.

    IF screen-name CP '*codprod1*'.
      IF create IS NOT INITIAL.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
      ENDLOOP.

"AT SELECTION-SCREEN OUTPUT.
 " LOOP AT SCREEN.

  "  if screen-name CP '*codprod1*'.
  CASE 'X'.
    WHEN create.
   "     screen-active = 0.

      AUTHORITY-CHECK OBJECT 'ZPROD_201'
       ID 'ACTVT' FIELD '01'.
      IF sy-subrc <> 0.
         MESSAGE: 'Você não tem autorização' TYPE 'I'.
         ELSE.
           " perform limpar_p.
           IF desc IS NOT INITIAL.
           PERFORM cod_prod USING '03' 'Z_DOCS_201'.
           wa_produto-produto = codprod.
           wa_produto-desc_produto = desc.
           wa_produto-moeda = moeda.
           wa_produto-preco = preco.
           wa_produto-tipoproduto  = tipoprod.
           APPEND wa_produto TO it_produto.
          INSERT zprodutos_201 FROM wa_produto.

          IF sy-subrc = 0.
            COMMIT WORK.
            MESSAGE: |'Produto { codprod } cadastrado com sucesso'  | TYPE 'S'.

             ELSE.
               ROLLBACK WORK.
                  WRITE: 'ERRO AO CADASTRAR'.
                    PERFORM limpar_p.
                  ENDIF.
                  ELSE.
                    WRITE: 'PREENCHA OS CAMPOS'.
                  ENDIF.

                  ENDIF.

WHEN read.
"screen-active = 1.
"read = ''.
AUTHORITY-CHECK OBJECT 'ZPROD_201'
ID 'ACTVT' FIELD '01'.
IF sy-subrc <> 0.
  MESSAGE 'Você não tem autorização!' TYPE 'I'.
*       Implement a suitable exception handling here

ELSE.
  SELECT * FROM zprodutos_201 INTO TABLE it_produto.
    IF sy-subrc = 0.
      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
        EXPORTING
          i_structure_name = 'zprodutos_201'
          i_save           = 'A'
        TABLES
          t_outtab         = it_produto
        EXCEPTIONS
          program_error    = 1
          OTHERS           = 2.
    ELSE.
      WRITE: 'Erro ao exportar ALV.'.
    ENDIF.
  ENDIF.
WHEN update.
 " screen-active = 1.

  AUTHORITY-CHECK OBJECT 'ZPROD_201'
    ID 'ACTVT' FIELD '02'.
  IF sy-subrc <> 0.
    MESSAGE 'Você não tem autorização!' TYPE 'I'.
*       Implement a suitable exception handling here

  ELSE.
     "PERFORM limpar_p.
    IF desc IS NOT INITIAL.
      UPDATE zprodutos_201 SET desc_produto = desc WHERE produto = codprod1.
      MESSAGE |Descrição do produto { desc } atualizada com sucesso| TYPE 'S'.
    ELSEIF preco IS NOT INITIAL.
      UPDATE zprodutos_201 SET preco = preco WHERE produto = codprod1.
       MESSAGE |Preço do produto { preco } atualizada com sucesso| TYPE 'S'.
    ELSEIF tipoprod IS NOT INITIAL.
      UPDATE zprodutos_201 SET tipoproduto = tipoprod WHERE produto = codprod1.
      MESSAGE |Descrição do produto { tipoprod } atualizada com sucesso| TYPE 'S'.
    ENDIF.

  ENDIF.


WHEN delete.
  "screen-active = 1.

  AUTHORITY-CHECK OBJECT 'ZPROD_201'
  ID 'ACTVT' FIELD '06'.
  IF sy-subrc <> 0.
    MESSAGE 'Você não tem autorização!' TYPE 'I'.
*       Implement a suitable exception handling here

  ELSE.
    perform limpar_p.
    SELECT * FROM zprodutos_201 INTO TABLE it_produto WHERE produto = codprod1.
      DELETE FROM zprodutos_201 WHERE produto = codprod1.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE: | Produto  { codprod1 } deletado com sucesso! | TYPE 'S'.

      ELSE.
        ROLLBACK WORK.
        WRITE: 'ERRO AO DELETAR'.
      ENDIF.
    ENDIF.
  WHEN OTHERS.

ENDCASE.
  "endif.
  "MODIFY SCREEN.
  "endloop.





*
*  IF sy-subrc <> 0.
*    ROLLBACK WORK.
*    WRITE: 'ERRO AO CADASTRAR'.
*
*  ELSE.
*    COMMIT WORK.
*    WRITE: 'CADASTRO COM SUCESSO'.


*    SELECT * FROM zprodutos_201 INTO TABLE it_produto.
*
*    IF sy-subrc = 0.
*      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*        EXPORTING
*          i_structure_name = 'zprodutos_201'
*          i_save           = 'A'
*        TABLES
*          t_outtab         = it_produto
*        EXCEPTIONS
*          program_error    = 1
*          OTHERS           = 2.
*
*    ELSE.
*      WRITE: 'Erro ao exportar ALV.'.
*    ENDIF.
*
*
*  ENDIF.





"  SELECT * FROM zprodutos_201
"INTO TABLE it_produtos.

"""""""""""""""""""""""""""""""""""""""""" SUBROTINA """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

FORM cod_prod USING nr_range TYPE inri-nrrangenr
       object TYPE inri-object.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = nr_range
      object      = object
*     QUANTITY    = '1'
*     SUBOBJECT   = ' '
*     TOYEAR      = '0000'
*     IGNORE_BUFFER                 = ' '
    IMPORTING
      number      = codprod
*     QUANTITY    =
*     RETURNCODE  =
* EXCEPTIONS
*     INTERVAL_NOT_FOUND            = 1
*     NUMBER_RANGE_NOT_INTERN       = 2
*     OBJECT_NOT_FOUND              = 3
*     QUANTITY_IS_0                 = 4
*     QUANTITY_IS_NOT_1             = 5
*     INTERVAL_OVERFLOW             = 6
*     BUFFER_OVERFLOW               = 7
*     OTHERS      = 8
    .

  IF sy-subrc NE 0.
    WRITE: 'Erro ao gerar código'.
  ENDIF.
ENDFORM.

FORM limpar_p.
            desc = ''.

              preco = ''.
              tipoprod = ''.
ENDFORM.
