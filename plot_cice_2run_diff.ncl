;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;************************************************

  ; hera
  RT1 = "/scratch2/NCEPDEV/stmp1/Denise.Worthen/"
  RT2 = "/scratch1/NCEPDEV/stmp2/Denise.Worthen/"
  RT3 = "/scratch2/NCEPDEV/stmp3/Denise.Worthen/"
  RT4 = "/scratch1/NCEPDEV/stmp4/Denise.Worthen/"

    hemi = "NH"
 ;   hemi = "SH"
 if(hemi .eq. "NH")then
  minlat =  66.0
  midlon = -45.0       
 else
  maxlat = -50.0
  midlon =   0.0       
 end if

  ; these are in degrees
    rfactor = 1.0
   tlatname = "TLAT"
   tlonname = "TLON"

;************************************************
; read in netCDF file
;************************************************

     lstep = 1-1
     cyear = "2013"
      cmon = "04"
      cday = "06"
      csec = "00000"
     cdate = cyear+"-"+cmon+"-"+cday+"-"+csec

  runname = (/"cice5", "cice5_updated"/)
      rts = (/"S2S_RT/rt_275334","S2S_RT/rt_9721"/)
     cset = "/cpld_fv3_ccpp_384_mom6_cice_cmeps_1d_bmark_rt/"

     files = addfiles(RT2+rts+cset+"history/iceh_06h."+cyear+"-"+cmon+"-"+cday+"-00000.nc","r")

     print(rts(1)+" - "+rts(0))
     plottitle=runname(1)+" - "+runname(0)

         times = files[0]->time
     timeUnits = files[0]->time@units
  timeCalendar = files[0]->time@calendar

;************************************************
; add a poly line showing the polar seem along
; great circle path from (lon1,lat1) to (lon2,lat2)
;************************************************

   lon1=  60.00
   lon2=-120.00
   lat1=  60.00
   lat2=  60.00

;************************************************
; define the map
;************************************************

  wkstitle="ice_diff"
  ;wkstype="X11"
  wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ;drawNDCGrid(wks)
  plot = new(2,graphic)
   dum = new(2,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = False
  res@mpOutlineOn          = False

  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = True                 ; turn off individual colorbars

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                    ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = maxlat  
   res@mpCenterLonF = 0.0
  end if

  ;res@gsnRightString        = ""
  ;res@gsnCenterString       = ""

  res@gsnPolarLabelFontHeightF   = 0.020           ; change font height of labels
  res@gsnCenterStringFontHeightF = 0.020
  res@lbLabelFontHeightF         = 0.020     

  ;res@cnMissingValPerimOn     = False            ; turn on the missing value perimeter
  ;res@cnMissingValPerimColor  = "black"           ; outline the perimeter red
  res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
  res@cnMissingValFillColor   = "gray"          ; color fill missing areas blue

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"        ; color of lines
  pres@gsLineDashPattern =  1            ; dashes

;************************************************
; the subplot call
;************************************************
function subplot(ii,name,pltvar,pltlevs,palette)
begin
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
   res@cnFillPalette        = palette

  ;print(pltlevs)
  ;print(palette)

  splot = gsn_csm_contour_map_polar(wks,pltvar,res)    ; create the plot
  ;delete(res@cnLevels)
  ;delete(res@lbLabelStrings)
  return(splot)
end
; ***************************************************
; panel resources
; **************************************************

  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelYWhiteSpacePercent = 10
  resP@gsnPanelLabelBar      = False                 ; turn on a common labelbar for the entire panel plot

  resP@gsnPanelMainFontHeightF = 0.012           ; new resource added in NCL V6.4.0
  resP@gsnPanelMainString = plottitle+": "+cd_string(times(lstep),"%Y%N%D")+"@ "+csec+" secs "

;************************************************
;
;************************************************
 
         pltlevs = new((/3/),float)
    labelstrings = new((/2/),string)
    colormap = "BlueDarkRed18"
    ;colormap = "amwg256"

        ii = 0
     vname = "congel_h"
  ;   vname = "aice_h"
   pltlevs = (/-.5,.5,.05/)
  ;   vname = "sst_h"
  ; pltlevs = (/-.2,.2,.02/)
  res@gsnCenterString  = vname

  ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ivar@lon2d = files[0]->$tlonname$*rfactor
  ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

        ii = 1
     vname = "hi_h"
   pltlevs = (/-2.0,2.0,.2/)
 ;    vname = "fhocn_h"
 ;  pltlevs = (/-10.0,10.0,1.0/)
 ;    vname = "meltb_h"
 ;  pltlevs = (/-1.0,1.0,0.1/)
     vname = "sss_h"
   pltlevs = (/-0.5,0.5,0.05/)

  ;ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)
  ;ivar = ivar*100.0   ; in cm
  ; error in assuming constant Tf
   mfrz = -0.054
  ivar0 = files[0]->$vname$(lstep,:,:)
  ivar0 = ivar0*0.0 + 34.0*mfrz
  ivar1 = files[1]->$vname$(lstep,:,:)
  ivar1 = ivar1*mfrz
  ivar = ivar1
  ivar = ivar1 - ivar0
  ivar@units = " "
  ivar@long_name = " "
  res@gsnCenterString  = "Tfreeze"
  ;ivar = files[1]->$vname$(lstep,:,:)-files[0]->$vname$(lstep,:,:)

  ivar@lon2d = files[0]->$tlonname$*rfactor
  ivar@lat2d = files[0]->$tlatname$*rfactor
  plot(ii) = subplot(ii,vname,ivar(:,:),pltlevs,colormap)
   dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; make the panel
;************************************************

  gsn_panel(wks,plot,(/1,2/),resP)

  frame(wks)

  if(wkstype .eq. "png")then
   imcmd = "convert -trim "+wkstitle+".png "+wkstitle+".jpg"
   system(imcmd)
  end if
exit
end
