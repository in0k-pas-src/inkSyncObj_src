unit SingleWriterSection;{< [ inok SyncObj ] iN0k © 02.03.2012
//----------------------------------------------------------------------------//
// библиотека: другие обЪекты синхронизации потоков
// содержание: секция ОДНОГО писателя
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
uses core_SingleWriterSection;

type

 tSingleWriterSection=class
  protected
   _SWs:rSingleWriterSection;
    function _SWs_readers_NBR:longWord; inline;
  public
    constructor Create;
    destructor DESTROY;override;
  public
    property  readers_NBR:longWord read _SWs_readers_NBR;
    {[читатель] ПОПРОБОВАТЬ войти }
    function  readerTryOn:boolean; {$ifdef _INLINE_} inline; {$endif}
    {[читатель] ВОЙТИ для совместного использования данных}
    procedure readerEnter;         {$ifdef _INLINE_} inline; {$endif}
    {[читатель] ПОКИНУТЬ секцию}
    procedure readerLeave;         {$ifdef _INLINE_} inline; {$endif}
  public
    {[писатель] ПОПРОБОВАТЬ войти }
    function  writerTryOn:boolean; {$ifdef _INLINE_} inline; {$endif}
    {[писатель] ВОЙТИ для ЕКСКЛЮЗИВНОГО использования|изменения данных}
    procedure writerEnter;         {$ifdef _INLINE_} inline; {$endif}
    {[читатель] ПОКИНУТЬ секцию, освободить для использования}
    procedure writerLeave;         {$ifdef _INLINE_} inline; {$endif}
  end;

implementation

constructor tSingleWriterSection.Create;
begin
    Inherited Create;
    SingleWriterSection_Init(_SWs);
end;

destructor tSingleWriterSection.DESTROY;
begin
    SingleWriterSection_Done(_SWs);
end;

//------------------------------------------------------------------------------

function tSingleWriterSection._SWs_readers_NBR:longWord;
begin
    result:=SingleWriterSection_readers_NBR(_SWs);
end;

//------------------------------------------------------------------------------

function tSingleWriterSection.readerTryOn:boolean;
begin
    result:=SingleWriterSection_readerTryON(_SWs)<>0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tSingleWriterSection.readerEnter;
begin
    SingleWriterSection_readerEnter(_SWs);
end;

procedure tSingleWriterSection.readerLeave;
begin
    SingleWriterSection_readerLeave(_SWs);
end;

//------------------------------------------------------------------------------

function tSingleWriterSection.writerTryOn:boolean;
begin
    result:=SingleWriterSection_writerTryON(_SWs)<>0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tSingleWriterSection.writerEnter;
begin
    SingleWriterSection_writerEnter(_SWs);
end;

procedure tSingleWriterSection.writerLeave;
begin
    SingleWriterSection_writerLeave(_SWs);
end;

end.

