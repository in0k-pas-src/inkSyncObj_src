unit core_EasyCriticalSection;{< [ ink SyncObjs ] in0k © 02.03.2012
//----------------------------------------------------------------------------//
// библиотека: другие обЪекты синхронизации потоков
// содержание: ЯДРО простой критической секции
//----------------------------------------------------------------------------//}
interface
{%region /fold}//<---------------------------------------[ compiler directives ]
{}                                                                            {}
{}  //===== ОБЩЕЕ ======================                                      {}
{}  {$H+} //< ANSI строки                                                     {}
{}                                                                            {}
{}  //===== по КОМПИЛЯТОРУ =============                                      {}
{}  {$ifdef fpc} //<-- {FPC-Lazarus}                                          {}
{}    {$mode delphi} //< для пущей совместимости  с Delphi                    {}
{}    {$define _INLINE_}                                                      {}
{}  {$else} //---//<-- {Delphi}                                               {}
{}    {$IFDEF SUPPORTS_INLINE}                                                {}
{}      {$define _INLINE_}                                                    {}
{}    {$endif}                                                                {}
{}  {$endif}                                                                  {}
{}                                                                            {}
{}  //===== финальные обобщения ========                                      {}
{}  {$ifOpt D+} //< режим дебуга ВКЛЮЧЕН { "боевой" INLINE }                  {}
{}    {$undef _INLINE_} //< дeбугить просче БЕЗ INLIN`а                       {}
{}  {$endif}                                                                  {}
{}                                                                            {}
{%endregion}//<------------------------------------------[ compiler directives ]
//uses syncobjs;

type

 rEasyCriticalSection= TRTLCriticalSection;
 pEasyCriticalSection=^rEasyCriticalSection;

procedure EasyCriticalSection_Init (var   ECs:rEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Init (const ECs:pEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Done (var   ECs:rEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Done (const ECs:pEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;

function  EasyCriticalSection_TryON(var   ECs:rEasyCriticalSection):longint;    {$ifdef _INLINE_} inline; {$endif} overload;
function  EasyCriticalSection_TryON(const ECs:pEasyCriticalSection):longint;    {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Enter(var   ECs:rEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Enter(const ECs:pEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Leave(var   ECs:rEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;
procedure EasyCriticalSection_Leave(const ECs:pEasyCriticalSection);            {$ifdef _INLINE_} inline; {$endif} overload;

implementation

{-D- ИНИЦИАЛИЗИРОВАТЬ для использования
     @param (ECs критическая секция)
 -D-}
procedure EasyCriticalSection_Init(var ECs:rEasyCriticalSection);
begin
    InitCriticalSection(ECs);
end;

{-D- ИНИЦИАЛИЗИРОВАТЬ для использования
     @param (ECs критическая секция)
 -D-}
procedure EasyCriticalSection_Init(const ECs:pEasyCriticalSection);
begin
    InitCriticalSection(ECs^);
end;

{-D- ЗАВЕРШИТЬ использование
     @param (ECs критическая секция)
 -D-}
procedure EasyCriticalSection_Done(var ECs:rEasyCriticalSection);
begin
    DoneCriticalsection(ECs);
end;

{-D- ЗАВЕРШИТЬ использование
     @param (ECs критическая секция)
 -D-}
procedure EasyCriticalSection_Done(const ECs:pEasyCriticalSection);
begin
    DoneCriticalsection(ECs^);
end;

//------------------------------------------------------------------------------

{-D- Попытаться войти в критическую секцию
     выполнение НЕ блокируется
     ---
     @param (ECs критическая секция)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..Leave` приведет к КРАХУ
 -D-}
function EasyCriticalSection_TryON(var ECs:rEasyCriticalSection):longint;
begin
    result:=TryEnterCriticalsection(ECs);
end;

{-D- Попытаться войти в критическую секцию
     выполнение НЕ блокируется
     ---
     @param (ECs критическая секция)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..Leave` приведет к КРАХУ
 -D-}
function EasyCriticalSection_TryON(const ECs:pEasyCriticalSection):longint;
begin
    result:=TryEnterCriticalsection(ECs^);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- ВХОД в критическую секцию.
     выполнение БЛОКИРУЕТСЯ, пока вход не будет осуществлен
     ---
     @param (ECs критическая секция)
     ---
     * НЕ парный вызов с `..Leave` приведет к КРАХУ
 -D-}
procedure EasyCriticalSection_Enter(var ECs:rEasyCriticalSection);
begin
    EnterCriticalsection(ECs)
end;

{-D- ВХОД в критическую секцию.
     выполнение БЛОКИРУЕТСЯ, пока вход не будет осуществлен
     ---
     @param (ECs критическая секция)
     ---
     * НЕ парный вызов с `..Leave` приведет к КРАХУ
 -D-}
procedure EasyCriticalSection_Enter(const ECs:pEasyCriticalSection);
begin
    EnterCriticalsection(ECs^)
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- вЫХОД из критической секции.
     просто "отмечается" что теперь эту секцию может занять кто-то другой
     ---
     @param (ECs критическая секция)
     ---
     * НЕ парный вызов с `..Enter` или `..TryON` приведет к КРАХУ
 -D-}
procedure EasyCriticalSection_Leave(var ECs:rEasyCriticalSection);
begin
    LeaveCriticalsection(ECs)
end;

{-D- вЫХОД из критической секции.
     просто "отмечается" что теперь эту секцию может занять кто-то другой
     ---
     @param (ECs критическая секция)
     ---
     * НЕ парный вызов с `..Enter` или `..TryON` приведет к КРАХУ
 -D-}
procedure EasyCriticalSection_Leave(const ECs:pEasyCriticalSection);
begin
    LeaveCriticalsection(ECs^)
end;

end.

