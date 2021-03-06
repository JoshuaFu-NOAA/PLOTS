; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

begin

;************************************************
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

  runname = "cfsr"
  rtsrc= "/scratch2/NCEPDEV/climate/Denise.Worthen/WORK/DATM_SA/DATM/"
  
  datmflds = (/"mean_down_sw_flx",     \
               "mean_down_lw_flx",     \
               "mean_sensi_heat_flx",  \
               "mean_laten_heat_flx"   \
              /)
  nflds = dimsizes(datmflds)

  forcflds = (/"DSWRF",         \
               "DLWRF",         \
               "shtfl_ave",     \
               "lhtfl_ave"      \
              /)

;************************************************
; time step
;************************************************

  syear="2011"
  smonth="10"
    sday="01"
   shour="00"
   stime=syear+smonth+sday+shour
    
  ; create a timeaxis
  hourlist = fspan(0,49,49)
  ;print(hourlist)
     hours = hourlist(0:47)
  ;print(dimsizes(hours))
  ; create arrays
  years = 0*tointeger(hours)+tointeger(syear)
   mons = 0*tointeger(hours)+tointeger(smonth)
   days = 0*tointeger(hours)+tointeger(sday)
   mins = 0*tointeger(hours)
   secs = 0*tointeger(hours)

     units = "hours since "+syear+"-"+smonth+"-"+sday+" 00:00:00"
  time = cd_inv_calendar(years,mons,days,tointeger(hours),mins,secs,units,0)
  time!0 = "time"
  nsteps = dimsizes(time)
  print("nsteps = "+nsteps)
  print(time)

   datmlist=systemfunc("ls "+rtsrc+"DATM_OUTPUT/"+runname+"/field_atm_exporta_*.nc")
   forclist=systemfunc("ls "+rtsrc+"DATM_INPUT/"+runname+"."+syear+"*.nc")
  ;print(datmlist)
  print(forclist)
  print(dimsizes(datmlist))
   nhours = dimsizes(datmlist)
  print(dimsizes(forclist))
  ; forcing data is 6 hourly
    nfout = 6
  ; the number of forcing files
  nfhours = dimsizes(datmlist)/nfout
  print(nfhours)

  datmfiles=addfiles(datmlist,"r")
  forcfiles=addfiles(forclist(0:nfhours-1),"r")
  print(forcfiles)

  ; atm grid coords
  gmedx_a = addfile(rtsrc+"DATM_OUTPUT/"+runname+"/atmlonc.nc","r")
  gmedy_a = addfile(rtsrc+"DATM_OUTPUT/"+runname+"/atmlatc.nc","r")
  ; atm coords
  atmlon=gmedx_a->atmlonc
  atmlat=gmedy_a->atmlatc
  atmlon@units = "degrees_east"
  atmlat@units = "degrees_north"
  ;printVarSummary(atmlon)
  ;printVarSummary(atmlat)

;************************************************
;
;************************************************

  ; pick a field to plot
  fldtoplot = 2
    fldname = forcflds(fldtoplot)
   dfldname = datmflds(fldtoplot)
   wkstitle = fldname
  ; special settings
       wgt = 1.0
  if(fldname .eq. "precp" .or. fldname .eq. "fprecp")then   ; make levels easier
       wgt = 3600.0
  end if

  ; pick lat/lon
  xlon = 170.0
  xlat =  20.0
  ; nearest pt on the datm export
  ij = getind_latlon2d(atmlat,atmlon,xlat,xlon)
  ;print(ij)
  ilat = ij(0,0)
  ilon = ij(0,1)
  print(ilat+" "+ilon)

  fpt = forcfiles[:]->$fldname$(:,{xlat},{xlon})
  fpt@_FillValue = default_fillvalue(typeof(fpt))
  ;fpt = fpt*wgt
  dpt = tofloat(datmfiles[:]->$dfldname$(:,ilat,ilon))
  ;copy_VarAtts(fpt,dpt)
  ;dpt = dpt*wgt
  ;printVarSummary(dpt)
 
  ntot = 2
  data_all = new((/ntot,dimsizes(time)/),float)
  ;print(dimsizes(data_all))

  data_all(0,:) = dpt
  data_all(1,0::6) = fpt(:)
 
  ;print(taxis+"   "+data_all(0,:)+"  "+data_all(1,:))

 ;labelstring = var@long_name+" ("+var@units+")"
 ;print(labelstring) 
 colors = (/"red", "blue"/)

;if(1 .eq. 0)then
;************************************************
;
;************************************************

 legendlabs = new((/ntot/),"string")
 legenddesc = new((/ntot/),"string")
 legendcols = new((/ntot/),"string")
 legendthik = new((/ntot/),"float")
 legenddash = new((/ntot/),"integer")
 do ii = 0,ntot-1
  ;legendlabs(ii) = RunLabs(ii)+RunDesc(ii)
  legendcols(ii) =  colors(ii)
  ;legendthik(ii) =  2.0
  ;legenddash(ii) =  0
  ;print(ii+" "+RunLabs(ii))
 end do

 ;print(legendlabs)
 ;print(legendcols)

;************************************************
;
;************************************************

  wkstype="X11"
  wkstitle=runname
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks = gsn_open_wks(wkstype,wkstitle)              ; send graphics to PNG file
  
  ;drawNDCGrid(wks)

   plot = new(1  ,graphic)
  oplot = new(1  ,graphic)

 npanels = 1

;************************************************
;---Set plotting parameters
;************************************************

 res                   = True                      ; plot mods desired
 res@vpWidthF          = 0.70
 res@vpHeightF         = 0.30
 res@xyLineThicknessF  = 2.0
 ;res@tiYAxisString     = labelstring

 res@gsnDraw  = False
 res@gsnFrame = False

; 	default Format = "0@*+^sg"
; if(varname .eq. "exmod" .or. varname .eq. "armod")then
; res@tmYLFormat = "0*+^e"	; use "e" symbol, don't force 0's (see documentation)
; end if
; res@tmYLMinorOn = False	; turn the minor tick marks off
; res@tmXBPrecision = 6		; set the precision to 6 significant digits

; res@trXMaxF = max(time)
; res@trXMinF = min(time)
 ;if(varname .ne. "tsfc" .and. varname .ne. "sst")then
 ; res@trYMinF = 0.0
 ;end if
 ;if(varname .eq. "sst")then
 ; res@trYMaxF = 6.0
 ;end if

 ;if(varname .eq. "hpond" .or. varname .eq. "hpond_ai")then
 ; res@trYMaxF = 0.2
 ; res@trYMinF = 0.0
 ;end if
 ;if(varname .eq. "meltt")then
 ; res@trYMaxF = 6.0
 ;end if

 ;restick = True
 ;restick@ttmFormat = "%D%C"
 ;restick@ttmValues = taxis
 ;time_axis_labels(taxis,res,restick)

;***********************************************
; legend resources
;***********************************************

;************************************************
; for legend_ndc
;************************************************

  lgres                      = True
  lgres@vpWidthF             = 0.30                  ; width of legend (NDC)
  lgres@vpHeightF            = 0.12                  ; height of legend (NDC)

  lgres@lgAutoManage         = False

  lgres@lgPerimOn            = False                 ; turn off perimeter
  lgres@lgMonoLineThickness  = False                 ; allow different line thicknesses
  ;lgres@lgDashIndexes        = legenddash
  lgres@lgItemCount          = ntot
  lgres@lgLabelsOn           = True
  lgres@lgLineColors         = legendcols
  ;lgres@lgLineThicknesses    = legendthik
  ;lgres@lgLineLabelStrings   = legendlabs
  ;lgres@lgLabelFontHeightF   = 0.20

  ;lgres@lgMonoLineLabelFontColor = True               ; one label color

;************************************************
;  for simple_legend
;************************************************

  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels

  gres@Position             = "Bottom"
  gres@YPosPercent          =  10.      ; from the bottom
  gres@XPosPercent          =  5.
  gres@ItemSpacePercent     =  10.
  lineres@LineLengthPercent =  5.      ; expressed as %, 0->100, length of line

  textres@lgLabels           = legendlabs
  textres@lgLabelFontHeights = 0.020

  lineres@lgLineColors      = legendcols
  ;lineres@lgLineThicknesses = legendthik      ; line thicknesses

;************************************************
; Make the plot
;************************************************

  ; mmax = max(data_all(:,:))
  ; mmin = min(data_all(:,:))
  ; res@trYMinF = mmin
  ; res@trYMaxF = mmax
 res@xyMarkLineModes   = "MarkLines"                ; choose which have markers
 res@xyMarkers         =  16                      ; choose type of marker  
 res@xyMarkerColor     = "blue"                    ; Marker color
 res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

    plot(0) = gsn_csm_xy (wks,time,data_all( 0,:),res) ; create plot

 ores                   = True                     ; plot mods desired
 ores@xyMarkLineModes   = "Markers"                ; choose which have markers
 ores@xyMarkers         =  16                      ; choose type of marker  
 ores@xyMarkerColor     = "red"                    ; Marker color
 ores@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

   oplot(0) = gsn_csm_xy (wks,time,data_all( 1,:),ores) ; create plot
  overlay(plot,oplot)

  xx = 0.60
  yy = 0.15
  ;gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)
;************************************************
;
;************************************************

  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 5
  resP@gsnPanelCenter      = False

  gsn_panel(wks,plot,(/1,1/),resP)           ; now draw as one plot
  ;frame(wks)

;************************************************
;
;************************************************

  ;xx = 0.80
  ;yy = 0.10
  ;gsn_legend_ndc(wks,ntot,legendlabs,xx,yy,lgres)

  ;gsn_panel(wks,plot,(/nrows,ncols/),resP)           ; now draw as one plot
  ;simple_legend_ndc(wks, genres, lineres, textres)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
;end if
exit
end
