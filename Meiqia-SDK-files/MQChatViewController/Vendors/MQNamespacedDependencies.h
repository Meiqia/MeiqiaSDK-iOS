// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(MEIQIA, symbol)
#endif


// Classes

#ifndef CustomIOSAlertView
#define CustomIOSAlertView __NS_SYMBOL(CustomIOSAlertView)
#endif

#ifndef FBBitmapFont
#define FBBitmapFont __NS_SYMBOL(FBBitmapFont)
#endif

#ifndef FBBitmapFontView
#define FBBitmapFontView __NS_SYMBOL(FBBitmapFontView)
#endif

#ifndef FBFontSymbol
#define FBFontSymbol __NS_SYMBOL(FBFontSymbol)
#endif

#ifndef FBLCDFont
#define FBLCDFont __NS_SYMBOL(FBLCDFont)
#endif

#ifndef FBLCDFontView
#define FBLCDFontView __NS_SYMBOL(FBLCDFontView)
#endif

#ifndef FBSquareFont
#define FBSquareFont __NS_SYMBOL(FBSquareFont)
#endif

#ifndef FBSquareFontView
#define FBSquareFontView __NS_SYMBOL(FBSquareFontView)
#endif

#ifndef HPGrowingTextView
#define HPGrowingTextView __NS_SYMBOL(HPGrowingTextView)
#endif

#ifndef HPTextViewInternal
#define HPTextViewInternal __NS_SYMBOL(HPTextViewInternal)
#endif

#ifndef LevelMeterState
#define LevelMeterState __NS_SYMBOL(LevelMeterState)
#endif

//functions
#ifndef inputBufferHandler
#define inputBufferHandler __NS_SYMBOL(inputBufferHandler)
#endif

//externs
#ifndef buttonHeight
#define buttonHeight __NS_SYMBOL(buttonHeight)
#endif

#ifndef buttonSpacerHeight
#define buttonSpacerHeight __NS_SYMBOL(buttonSpacerHeight)
#endif

#ifndef didKeyboardDisplay
#define didKeyboardDisplay __NS_SYMBOL(didKeyboardDisplay)
#endif

#ifndef currentKeyboardSize
#define currentKeyboardSize __NS_SYMBOL(currentKeyboardSize)
#endif
