CLASS zcl_mm_down_payment_bgpf DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.

    METHODS add
      IMPORTING journal_entry TYPE ty_je_deep.

    METHODS process.

  PRIVATE SECTION.
    DATA je_deep TYPE ty_je_deep.
ENDCLASS.



CLASS ZCL_MM_DOWN_PAYMENT_BGPF IMPLEMENTATION.


  METHOD add.
    je_deep = journal_entry.
  ENDMETHOD.


  METHOD process.
    MODIFY ENTITIES OF I_JournalEntryTP
           ENTITY JournalEntry
           EXECUTE Post FROM je_deep
           FAILED DATA(ls_failed_deep)
" TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(ls_reported_deep)
           " TODO: variable is assigned but never used (ABAP cleaner)
           MAPPED DATA(ls_mapped_deep).

    IF ls_failed_deep IS INITIAL.

      COMMIT ENTITIES BEGIN
             RESPONSE OF i_journalentrytp
             " TODO: variable is assigned but never used (ABAP cleaner)
             FAILED DATA(lt_commit_failed)
             " TODO: variable is assigned but never used (ABAP cleaner)
             REPORTED DATA(lt_commit_reported).
      COMMIT ENTITIES END.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
