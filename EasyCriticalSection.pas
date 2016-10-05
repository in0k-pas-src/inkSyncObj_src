unit EasyCriticalSection;{< [ inok SyncObj ] iN0k © 02.03.2012
//----------------------------------------------------------------------------//
// библиотека: другие обЪекты синхронизации потоков
// содержание: ПРОСТАЯ критической секции
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
uses core_EasyCriticalSection;

type

 tEasyCriticalSection=class
  protected
   _ECs:rEasyCriticalSection;
  public
    constructor Create;
    destructor DESTROY;override;
  public
    { ПОПРОБОВАТЬ войти в Критическую секцию }
    function  TryOn:boolean; {$ifdef _INLINE_} inline; {$endif}
    { ВОЙТИ в Критическую секцию }
    procedure Enter;         {$ifdef _INLINE_} inline; {$endif}
    { ПОКИНУТЬ Критическую секцию (освободить) }
    procedure Leave;         {$ifdef _INLINE_} inline; {$endif}
  end;

implementation

constructor tEasyCriticalSection.Create;
begin
    Inherited Create;
    EasyCriticalSection_Init(_ECs);
end;

destructor tEasyCriticalSection.DESTROY;
begin
    EasyCriticalSection_Done(_ECs);
end;

//------------------------------------------------------------------------------

procedure tEasyCriticalSection.Enter;
begin
    EasyCriticalSection_Enter(_ECs);
end;

procedure tEasyCriticalSection.Leave;
begin
    EasyCriticalSection_Leave(_ECs);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function tEasyCriticalSection.TryOn:boolean;
begin
    result:=EasyCriticalSection_TryON(_ECs)<>0;
end;

end.
