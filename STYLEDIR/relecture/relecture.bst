%% relecture.bst : les entrées courtes de la version de relecture (make relecture).
%% Pour chaque clé citée : \rlentry{clé}{Auteurs.}{Titre.}{Lieu, année.}
%% Auteurs : noms de famille, « et al. » au-delà de quatre. Lieu : journal, actes, institution
%% (avec le numéro, pour les prépublications), coupé à 90 caractères.
%% Lancé par SCRIPTS/relecture.sh sur <job>-refs.aux (les \citation et le \bibdata du document).

ENTRY
  { author editor title year journal booktitle institution school
    publisher howpublished number }
  {}
  {}

INTEGERS { nameptr namesleft numnames }
STRINGS { s t }

MACRO {jan} {"January"}    MACRO {feb} {"February"}   MACRO {mar} {"March"}
MACRO {apr} {"April"}      MACRO {may} {"May"}        MACRO {jun} {"June"}
MACRO {jul} {"July"}       MACRO {aug} {"August"}     MACRO {sep} {"September"}
MACRO {oct} {"October"}    MACRO {nov} {"November"}   MACRO {dec} {"December"}

FUNCTION {not} { { #0 } { #1 } if$ }

%% Les types d'entrée, déclarés pour faire taire bibtex : toutes passent par output.entry.
FUNCTION {article} { }        FUNCTION {book} { }          FUNCTION {booklet} { }
FUNCTION {inbook} { }         FUNCTION {incollection} { }  FUNCTION {inproceedings} { }
FUNCTION {conference} { }     FUNCTION {manual} { }        FUNCTION {mastersthesis} { }
FUNCTION {misc} { }           FUNCTION {phdthesis} { }     FUNCTION {proceedings} { }
FUNCTION {techreport} { }     FUNCTION {unpublished} { }   FUNCTION {online} { }
FUNCTION {default.type} { }

FUNCTION {format.names}
{ 's :=
  s num.names$ 'numnames :=
  numnames #4 >
    { s #1 "{vv~}{ll}" format.name$ " et~al." * }
    { #1 'nameptr :=
      numnames 'namesleft :=
      { namesleft #0 > }
        { s nameptr "{vv~}{ll}" format.name$ 't :=
          nameptr #1 >
            { namesleft #1 >
                { ", " * t * }
                { t "others" =
                    { " et~al." * }
                    { numnames #2 > { ", and " } { " and " } if$ * t * }
                  if$
                }
              if$
            }
            't
          if$
          nameptr #1 + 'nameptr :=
          namesleft #1 - 'namesleft :=
        }
      while$
    }
  if$
}

FUNCTION {names}
{ author empty$
    { editor empty$ { "" } { editor format.names " (ed.)" * } if$ }
    { author format.names }
  if$
  duplicate$ empty$ 'skip$ { add.period$ } if$
}

FUNCTION {venue}
{ journal empty$ not
    { journal }
    { booktitle empty$ not
        { booktitle }
        { institution empty$ not
            { institution number empty$ 'skip$ { " " * number * } if$ }
            { school empty$ not
                { school }
                { howpublished empty$ not
                    { howpublished }
                    { publisher empty$ { "" } { publisher } if$ }
                  if$
                }
              if$
            }
          if$
        }
      if$
    }
  if$
  duplicate$ text.length$ #90 >
    { #90 text.prefix$ "\ldots" * }
    'skip$
  if$
}

FUNCTION {venue.year}
{ venue 't :=
  year empty$
    { t }
    { t empty$ { year } { t ", " * year * } if$ }
  if$
  duplicate$ empty$ 'skip$ { add.period$ } if$
}

FUNCTION {output.entry}
{ "\rlentry{" cite$ * "}{" * write$
  names write$
  "}{" write$
  title empty$ { "" } { title add.period$ } if$ write$
  "}{" write$
  venue.year write$
  "}" write$
  newline$
}

READ

ITERATE {output.entry}
