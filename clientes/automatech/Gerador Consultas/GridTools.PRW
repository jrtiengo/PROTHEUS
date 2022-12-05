#include 'protheus.ch'

#define GRID_MOVEUP       0
#define GRID_MOVEDOWN     1
#define GRID_MOVEHOME     2
#define GRID_MOVEEND      3
#define GRID_MOVEPAGEUP   4
#define GRID_MOVEPAGEDOWN 5   
#define GRID_HSCROLL_ASNEEDED   0
#define GRID_HSCROLL_ALWAYSOFF  1
#define GRID_HSCROLL_ALWAYSON   2


/*/{Protheus.doc} GridTools
Grid for selection fields
@author Lucas Moresco
@since 20/03/2016
@version 1.0
/*/
Class GridTools 
	
	DATA oGrid 
    DATA oFrame
    DATA oButtonsFrame 
    DATA oButtonHome   
    DATA oButtonPgUp   
    DATA oButtonUp 
    DATA oButtonDown   
    DATA oButtonPgDown 
    DATA oButtonEnd
    DATA aData 
    DATA nLenData  
    DATA nRecNo
    DATA nCursorPos    
    DATA nVisibleRows
    DATA nFreeze
    DATA nHScroll
    DATA aHeader
       
    METHOD New(oDlg) CONSTRUCTOR   
    METHOD onMove( o,nMvType,nCurPos,nOffSet,nVisRows )
    METHOD isBof() 
    METHOD isEof() 
    METHOD ShowData( nFirstRec, nCount )   
    METHOD ClearRows() 
    METHOD DoUpdate()
    METHOD DoLineUpdate(n)        
    METHOD SelectRow(n)            
    METHOD GoHome()                        
    METHOD GoEnd() 
    METHOD GoPgUp()    
    METHOD GoPgDown()      
    METHOD GoUp(nOffSet)   
    METHOD GoDown(nOffSet)     
    METHOD SetCSS(cCSS)
    METHOD SetFreeze(nFreeze)
    METHOD SetHScrollState(nHScroll)
    METHOD GetHeader()
    METHOD GetPosField(cField)

EndClass

METHOD New(oDlg, aData, aHeader, nPosTop, nPosLeft, nWidht, nHeight) CLASS GridTools  
    Local oFont
           
    ::oFrame:= tPanel():New(nPosTop,nPosLeft,,oDlg,,,,,,nWidht,nHeight )   
    ::nRecNo:= 1   
    ::nCursorPos:= 0       
    ::nVisibleRows:= 14
    // Forçado para 1o ::GoEnd()       
    ::aHeader := aHeader
    ::aData   := aData
    
    ::nLenData:= Len(aData)    
    ::oGrid:= tGrid():New( ::oFrame )  
    ::oGrid:Align:= CONTROL_ALIGN_ALLCLIENT
       
    //oFont := TFont():New('Tahoma',,-32,.T.)
    //::oGrid:SetFont(oFont)  
    //::oGrid:setRowHeight(50)                         
       
    ::oButtonsFrame:= tPanel():New(0,0,, ::oFrame,,,,,, 10,200,.F.,.T. )   
    ::oButtonsFrame:Align:= CONTROL_ALIGN_RIGHT    
    ::oButtonHome:= tBtnBmp():NewBar( "VCTOP.BMP",,,,, {||::GoHome()},,::oButtonsFrame ) 
    ::oButtonHome:Align:= CONTROL_ALIGN_TOP
    ::oButtonPgUp:= tBtnBmp():NewBar( "VCPGUP.BMP",,,,, {||::GoPgUp()},,::oButtonsFrame )
    ::oButtonPgUp:Align:= CONTROL_ALIGN_TOP
    ::oButtonUp:= tBtnBmp():NewBar( "VCUP.BMP",,,,,{||::GoUp(1)},,::oButtonsFrame )
    ::oButtonUp:Align:= CONTROL_ALIGN_TOP
    ::oButtonEnd:= tBtnBmp():NewBar( "VCBOTTOM.BMP",,,,, {||::GoEnd()},,::oButtonsFrame )
    ::oButtonEnd:Align:= CONTROL_ALIGN_BOTTOM
    ::oButtonPgDown:= tBtnBmp():NewBar( "VCPGDOWN.BMP",,,,, {||::GoPgDown()},,::oButtonsFrame )
    ::oButtonPgDown:Align:= CONTROL_ALIGN_BOTTOM
    ::oButtonDown:= tBtnBmp():NewBar( "VCDOWN.BMP",,,,, {||::GoDown(1)},,::oButtonsFrame )
    ::oButtonDown:Align:= CONTROL_ALIGN_BOTTOM
    
    
    For ix:= 1 To Len(::aHeader)
    	::oGrid:addColumn(ix, ::aHeader[ix], SetSizeColumn(aData, ix), CONTROL_ALIGN_LEFT )
    Next
    
    ::oGrid:bCursorMove:= {|o,nMvType,nCurPos,nOffSet,nVisRows| ::onMove(o,nMvType,nCurPos,nOffSet,nVisRows) }  
    ::ShowData(1)   
    ::SelectRow( ::nCursorPos )  
    
    // configura acionamento do duplo clique   
    //::oGrid:bLDblClick:= {|| U_itemClick(Self), ::DoLineUpdate(::nRecno) }
    
RETURN
METHOD isBof() CLASS GridTools
RETURN  ( ::nRecno==1 )
METHOD isEof() CLASS GridTools
RETURN ( ::nRecno==::nLenData )
METHOD GoHome() CLASS GridTools
    if ::isBof()
        return
    endif
    ::nRecno = 1
    ::oGrid:ClearRows()
    ::ShowData( 1, ::nVisibleRows )   
    ::nCursorPos:= 0
    ::SelectRow( ::nCursorPos )
RETURN
METHOD GoEnd() CLASS GridTools 
    if ::isEof() 
        return
    endif                                      
       
    ::nRecno:= ::nLenData
    ::oGrid:ClearRows()
    ::ShowData( ::nRecno - ::nVisibleRows + 1, ::nVisibleRows ) 
    ::nCursorPos:= ::nVisibleRows-1
    ::SelectRow( ::nCursorPos )
RETURN
METHOD GoPgUp() CLASS GridTools

Local cb    := ""
Local cTmp1 := ""
Local cTmp2 := ""
    
    if ::isBof()
        return
    endif                               
       
    // força antes ir para a 1a linha da grid          
    if ::nCursorPos != 0   
        ::nRecno -= ::nCursorPos
        if ::nRecno <= 0
            ::nRecno:=1
        endif
        ::nCursorPos:= 0
    
        cb    := ""
        cTmp1 := "{|o| {"
        	
        For iy:= 1 To Len(::aData[1])
        	
        	If iy < Len(::aData[1]) 
        		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"],"
        	Else
        		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"]"
        	EndIf
        	
        Next
        
        cTmp2 := "}}"
        cb := cTmp1 + cb + cTmp2 
    
        ::oGrid:setRowData( ::nCursorPos, &cb )
        //::oGrid:setRowData( ::nCursorPos, {|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } } )
   
    else
        ::nRecno -= ::nVisibleRows
        if ::nRecno <= 0
            ::nRecno:=1
        endif
        ::oGrid:ClearRows()
        ::ShowData( ::nRecno, ::nVisibleRows )
        ::nCursorPos:= 0
    endif
    ::SelectRow( ::nCursorPos )
RETURN
METHOD GoPgDown() CLASS GridTools

Local nLastVisRow
Local cb    := ""
Local cTmp1 := ""
Local cTmp2 := ""
       
    if ::isEof()
        return
    endif                                        
       
    // força antes ir para a última linha da grid
    nLastVisRow:= ::nVisibleRows-1
       
    if ::nCursorPos!=nLastVisRow   
       
        if ::nRecno+nLastVisRow > ::nLenData
            nLastVisRow:= ( ::nRecno+nLastVisRow ) - ::nLenData
            ::nRecno:= ::nLenData
        else
            ::nRecNo += nLastVisRow
        endif
           
        ::nCursorPos:= nLastVisRow
        
        cb    := ""
        cTmp1 := "{|o| {"
        
        For iy:= 1 To Len(::aData[1])
        	
        	If iy < Len(::aData[1]) 
        		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"],"
        	Else
        		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"]"
        	EndIf
        	
        Next
        
        cTmp2 := "}}"
        cb := cTmp1 + cb + cTmp2 
    
        ::oGrid:setRowData( ::nCursorPos, &cb )        
        //::oGrid:setRowData( ::nCursorPos, {|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } } )

    else
        ::oGrid:ClearRows()
        ::nRecno += ::nVisibleRows
           
        if ::nRecno > ::nLenData
            ::nVisibleRows = ::nRecno-::nLenData
            ::nRecno:= ::nLenData
        endif
           
        ::ShowData( ::nRecNo - ::nVisibleRows + 1, ::nVisibleRows )
        ::nCursorPos:= ::nVisibleRows-1
    endif  
       
    ::SelectRow( ::nCursorPos )
RETURN
       
METHOD GoUp(nOffSet) CLASS GridTools

Local lAdjustCursor:= .F.
Local cb    := ""
Local cTmp1 := ""
Local cTmp2 := ""

    if ::isBof()
        RETURN
    endif
    if ::nCursorPos==0
        ::oGrid:scrollLine(-1)
        lAdjustCursor:= .T.
    else         
        ::nCursorPos -= nOffSet
    endif
    ::nRecno -= nOffSet   
       
    cb    := ""
    cTmp1 := "{|o| {"
    
    For iy:= 1 To Len(::aData[1])
        	
    	If iy < Len(::aData[1]) 
    		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"],"
        Else
        	cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"]"
        EndIf
    Next
        
    cTmp2 := "}}"
    cb := cTmp1 + cb + cTmp2 
    
    ::oGrid:setRowData( ::nCursorPos, &cb ) 
    //::oGrid:setRowData( ::nCursorPos, {|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } } )
       
    if lAdjustCursor 
        ::nCursorPos:= 0
    endif
    ::SelectRow( ::nCursorPos )
RETURN
METHOD GoDown(nOffSet) CLASS GridTools

Local lAdjustCursor:= .F.   
Local cb    := ""
Local cTmp1 := ""
Local cTmp2 := ""

    if ::isEof()
        RETURN
    endif     
       
    if ::nCursorPos==::nVisibleRows-1
        ::oGrid:scrollLine(1)
        lAdjustCursor:= .T.
    else
        ::nCursorPos += nOffSet
    endif                
    ::nRecno += nOffSet
       
    cb    := ""
    cTmp1 := "{|o| {"
    
    For iy:= 1 To Len(::aData[1])
        	
    	If iy < Len(::aData[1]) 
    		cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"],"
        Else
        	cb+= " Self:aData["+AllTrim(Str(::nRecno))+","+AllTrim(Str(iy))+"]"
        EndIf
    Next
        
    cTmp2 := "}}"
    cb := cTmp1 + cb + cTmp2 
    
    // atualiza linha corrente 
    ::oGrid:setRowData( ::nCursorPos, &cb ) 
    //::oGrid:setRowData( ::nCursorPos, {|o| { ::aData[::nRecno,1], ::aData[::nRecno,2], ::aData[::nRecno,3] } } )
    
    
    if lAdjustCursor
        ::nCursorPos:= ::nVisibleRows-1
    endif
    ::SelectRow( ::nCursorPos )      
    
RETURN
METHOD onMove( oGrid,nMvType,nCurPos,nOffSet,nVisRows ) CLASS GridTools                         
    ::nCursorPos:= nCurPos
    ::nVisibleRows:= nVisRows
       
    if nMvType == GRID_MOVEUP 
        ::GoUp(nOffSet)
    elseif nMvType == GRID_MOVEDOWN      
        ::GoDown(nOffSet)
    elseif nMvType == GRID_MOVEHOME          
        ::GoHome()
    elseif nMvType == GRID_MOVEEND
        ::GoEnd() 
    elseif nMvType == GRID_MOVEPAGEUP
        ::GoPgUp()
    elseif nMvType == GRID_MOVEPAGEDOWN
        ::GoPgDown()
    endif
RETURN            
METHOD ShowData( nFirstRec, nCount ) CLASS GridTools
    local i, nRec, ci
    Local cb := ""
    DEFAULT nCount:=30
       
    for i=0 to nCount-1
        nRec:= nFirstRec+i
        if nRec > ::nLenData
            RETURN
        endif
        
        ci    := AllTrim(Str(nRec))            
        cb    := ""
        cTmp1 := "{|o| {"
        	
        For iy:= 1 To Len(::aData[1])
        	
        	If iy < Len(::aData[1]) 
        		cb+= " Self:aData["+ci+","+AllTrim(Str(iy))+"],"
        	Else
        		cb+= " Self:aData["+ci+","+AllTrim(Str(iy))+"]"
        	EndIf
        	
        Next
        
        cTmp2 := "}}"
        
        cb := cTmp1 + cb + cTmp2 
        
        
        ::oGrid:setRowData( i, &cb )
    next i
RETURN
METHOD ClearRows() CLASS GridTools
    ::oGrid:ClearRows()
    ::nRecNo:=1
RETURN
METHOD DoUpdate() CLASS GridTools    
    ::nRecNo:=1
    ::Showdata(1)
    ::SelectRow(0)
RETURN

METHOD DoLineUpdate(n) CLASS GridTools
    //::nRecNo:=n
    //::Showdata(n)
    //::SelectRow(n)
RETURN

METHOD SelectRow(n) CLASS GridTools
    ::oGrid:setSelectedRow(n)
RETURN          
METHOD SetCSS(cCSS) CLASS GridTools
    ::oGrid:setCSS(cCSS)
RETURN     
   
METHOD SetFreeze(nFreeze) CLASS GridTools
    ::nFreeze := nFreeze
    ::oGrid:nFreeze := nFreeze
RETURN
METHOD SetHScrollState(nHScroll) CLASS GridTools
    ::nHScroll := nHScroll
    ::oGrid:nHScroll := nHScroll
RETURN
METHOD GetHeader() CLASS GridTools
RETURN(::aHeader)
METHOD GetPosField(cField) CLASS GridTools

Local nPosRet := 0

	nPosRet := AScan(::aHeader, cField)
	
RETURN(nPosRet)

Static Function SetSizeColumn(aData, nPosHeader)

	Local nMajorSize := 0
	Local nMinorSize := 10
	Local nMultip    := 7

	For iw := 1 To Len(aData)
	
		If (Len(AllTrim(aData[iw][nPosHeader])) > nMajorSize)
			nMajorSize := Len(AllTrim(aData[iw][nPosHeader]))
		EndIf
		
	Next 

	If (nMajorSize > nMinorSize)
		nSize := nMajorSize * nMultip
	Else
		nSize := nMinorSize * (nMultip)	
	EndIf
	
Return(nSize)
