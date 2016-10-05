unit core_SingleWriterSection;{< [ ink SyncObj ] in0k © 02.03.2012
//----------------------------------------------------------------------------//
// библиотека: другие обЪекты синхронизации потоков
// содержание: ЯДРО "секции" одного ПИСАТЕЛЯ
//----------------------------------------------------------------------------//}
interface
{%region /fold}//<---------------------------------------[ compiler directives ]
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
uses core_EasyCriticalSection,
     sysutils;

type

 tSingleWriterSection_numberReaders=longWord; //<[4|4]-[0 .. 4294967295]

 rSingleWriterSection=record
    ECs:rEasyCriticalSection;                 //<[24|?]
    nbr:tSingleWriterSection_numberReaders;
  end;
 pSingleWriterSection=^rSingleWriterSection;

procedure SingleWriterSection_Init(const SWs:pSingleWriterSection);                {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_Init(var   SWs:rSingleWriterSection);                {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_Done(const SWs:pSingleWriterSection);                {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_Done(var   SWs:rSingleWriterSection);                {$ifdef _INLINE_} inline; {$endif} overload;

function  SingleWriterSection_readers_NBR(const SWs:pSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;
function  SingleWriterSection_readers_NBR(var   SWs:rSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;

function  SingleWriterSection_readerTryON(const SWs:pSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;
function  SingleWriterSection_readerTryON(var   SWs:rSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_readerEnter(const SWs:pSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_readerEnter(var   SWs:rSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_readerLeave(const SWs:pSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_readerLeave(var   SWs:rSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;

function  SingleWriterSection_writerTryON(const SWs:pSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;
function  SingleWriterSection_writerTryON(var   SWs:rSingleWriterSection):longint; {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_writerEnter(const SWs:pSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_writerEnter(var   SWs:rSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_writerLeave(const SWs:pSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;
procedure SingleWriterSection_writerLeave(var   SWs:rSingleWriterSection);         {$ifdef _INLINE_} inline; {$endif} overload;

implementation

{-D- ИНИЦИАЛИЗИРОВАТЬ "секцию" для использования
     @param (SWs секция одного писателя)
 -D-}
procedure SingleWriterSection_Init(const SWs:pSingleWriterSection);
begin
    SWs^.nbr:=0;
    EasyCriticalSection_Init(SWs^.ECs);
end;

{-D- ИНИЦИАЛИЗИРОВАТЬ "секцию" для использования
     @param (SWs секция одного писателя)
 -D-}
procedure SingleWriterSection_Init(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_Init(@SWs);
end;

{-D- ЗАВЕРШИТЬ использование "секции"
     @param (SWs секция одного писателя)
 -D-}
procedure SingleWriterSection_Done(const SWs:pSingleWriterSection);
begin
    SWs^.nbr:=0;
    EasyCriticalSection_Done(SWs^.ECs);
end;

{-D- ЗАВЕРШИТЬ использование "секции"
     @param (SWs секция одного писателя)
 -D-}
procedure SingleWriterSection_Done(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_Done(@SWs)
end;

//------------------------------------------------------------------------------

{-D- сколько читателей в "секции".
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(сколько читателей в "секции")
 -D-}
function SingleWriterSection_readers_NBR(const SWs:pSingleWriterSection):longint;
begin
    result:=SWs^.nbr;
end;

{-D- сколько читателей в "секции".
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(сколько читателей в "секции")
 -D-}
function SingleWriterSection_readers_NBR(var SWs:rSingleWriterSection):longint;
begin
    result:=SingleWriterSection_readers_NBR(@SWs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- Попытаться войти в "секцию" ЧИТАТЕЛЕМ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..readerLeave` приведет к КРАХУ
 -D-}
function SingleWriterSection_readerTryON(const SWs:pSingleWriterSection):longint;
begin
    result:=EasyCriticalSection_TryON(SWs^.ECs); //< пытаемся войти
    if result<>0 then begin                      //< мы ВОШЛИ => писателя НЕТ
        inc(SWs^.nbr);                           //< отмечаемся как ЧИТАТЕЛЬ
        EasyCriticalSection_Leave(SWs^.ECs);     //< уходим из защищаемой зоны
    end;
end;

{-D- Попытаться войти в "секцию" ЧИТАТЕЛЕМ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..readerLeave` приведет к КРАХУ
 -D-}
function SingleWriterSection_readerTryON(var SWs:rSingleWriterSection):longint;
begin
    result:=SingleWriterSection_readerTryON(@SWs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- ВХОД в "секцию" как ЧИТАТЕЛЯ.
     !!! выполнение БЛОКИРУЕТСЯ !!! пока вход не будет осуществлен
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..readerLeave` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_readerEnter(const SWs:pSingleWriterSection);
begin
    EasyCriticalSection_Enter(SWs^.ECs); //< если смогли пройти => писателя НЕТ
        inc(SWs^.nbr);                   //< отмечаемся как ЧИТАТЕЛЬ
    EasyCriticalSection_Leave(SWs^.ECs); //< уходим из защищаемой зоны
end;

{-D- ВХОД в "секцию" как ЧИТАТЕЛЯ.
     !!! выполнение БЛОКИРУЕТСЯ !!! пока вход не будет осуществлен
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..readerLeave` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_readerEnter(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_readerEnter(@SWs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- вЫХОД из "секции" как ЧИТАТЕЛЯ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..readerEnter` или `..readerTryON` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_readerLeave(const SWs:pSingleWriterSection);
begin // !!!!! ВНЕ защищенной зоны !!!! //< потому и InterLocked
    InterLockedDecrement(SWs^.nbr);      //< читатель УШёЛ
end;

{-D- вЫХОД из "секции" как ЧИТАТЕЛЯ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..readerEnter` или `..readerTryON` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_readerLeave(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_readerLeave(@SWs);
end;

//------------------------------------------------------------------------------

{-D- Попытаться войти в "секцию" ПИСАТЕЛЕМ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..writerLeave` приведет к КРАХУ
 -D-}
function SingleWriterSection_writerTryON(const SWs:pSingleWriterSection):longint;
begin // логика такова, смогли захватить секцию -- хорошо
      // но там могут быть читатели, если они есть то мы выходим
    result:=EasyCriticalSection_TryON(SWs^.ECs); //< пытаемся войти
    if result<>0 then begin                      //< мы ВОШЛИ и запЁрли вход
        {todo : тодо, подумать может сделать тут несколько проверок "SpinCount"}
        if SWs^.nbr>0 then begin
            EasyCriticalSection_Leave(SWs^.ECs);
            result:=0;
        end;
    end;
end;

{-D- Попытаться войти в "секцию" ПИСАТЕЛЕМ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     @return(0 -- НЕудача; иначе успешный вход)
     ---
     * НЕ парный вызов с `..writerLeave` приведет к КРАХУ
 -D-}
function SingleWriterSection_writerTryON(var SWs:rSingleWriterSection):longint;
begin
    result:=SingleWriterSection_writerTryON(@SWs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- ВХОД в "секцию" как ПИСАТЕЛЬ.
     выполнение БЛОКИРУЕТСЯ, пока вход не будет осуществлен
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..writerLeave` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_writerEnter(const SWs:pSingleWriterSection);
begin // !! SPIN блокировка возможнА !! //
    EasyCriticalSection_Enter(SWs^.ECs); //< запЁр входя ВСЕМ остальным
    while SWs^.nbr>0 do sleep(0);        //< ждем пока читатели уйдут
end;


{-D- ВХОД в "секцию" как ПИСАТЕЛЬ.
     выполнение БЛОКИРУЕТСЯ, пока вход не будет осуществлен
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..writerLeave` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_writerEnter(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_writerEnter(@SWs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{-D- вЫХОД из "секции" как ПИСАТЕЛЯ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..writerEnter` или `..writerTryON` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_writerLeave(const SWs:pSingleWriterSection);
begin // !!! "Элвис покинул здание" !!! //< можно поработать и другим
    EasyCriticalSection_Leave(SWs^.ECs);
end;

{-D- вЫХОД из "секции" как ПИСАТЕЛЯ.
     выполнение НЕ блокируется
     ---
     @param (SWs секция одного писателя)
     ---
     * НЕ парный вызов с `..writerEnter` или `..writerTryON` приведет к КРАХУ
 -D-}
procedure SingleWriterSection_writerLeave(var SWs:rSingleWriterSection);
begin
    SingleWriterSection_writerLeave(@SWs);
end;

end.
