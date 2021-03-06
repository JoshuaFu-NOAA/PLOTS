;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

  load "levscmapCICE.ncl"
;************************************************
begin
  batch="no"
  ;batch="yes"

  if(batch .eq. "no")then
     hemi = "NH"
   minlat = 66.0

    ;hemi = "SH"
  ;maxlat = -50.0
  end if
 
  ; these are in degrees
     rfactor=1.0
   tlatname="TLAT"
   tlonname="TLON"
   ulatname="ULAT"
   ulonname="ULON"

;************************************************
; make a list of the files from the run
; this will 'catch' the initial condition file
; until Bin rewrites the workflow to give the 
; initial condition file a more unique name
;************************************************

   icefilelist = systemfunc("ls "+dirname+"ice*.nc")
          icef = addfiles(icefilelist,"r")
        nfiles = dimsizes(icefilelist)
   ; print(nfiles)
   print(icefilelist)

   ; use the first file to retrieve grid variables
    tmask = icef[0]->tmask
    tarea = icef[0]->tarea
    uarea = icef[0]->uarea
  ; in radians, on t-grid
   rotang = icef[0]->ANGLET

  if(batch .eq. "no")then
   varname= "aice"
   ;varname = "hi"
   ;varname = "albsni"
   ;varname = "meltt"
   ;varname = "meltb"
   ;varname = "fpond"
   ;varname = "hpond"
   ;varname = "sst"
   ;varname = "sss"
   ;varname = "frzmlt"
  end if

  ; array contour levels for variables
      pltlevs = new((/3/),float)
      freturn = levscmapCICE(varname)
   pltlevs(:) = freturn[0]
   colormap   = freturn[1]

   runname = "c384"
  plotname = varname
   varname = varname+"_h"

  plottitle = plotname
  if(batch .eq. "no")then
   wkstitle = runname
  else
   wkstitle = runname+"_"+varname
  end if

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

  if(batch .eq. "no")then
   wkstype="X11"
  else
   wkstype="png"
  end if
   ;wkstype="X11"
   wkstype="png"
  wkstype@wkWidth=800
  wkstype@wkHeight=800
  wks   = gsn_open_wks (wkstype,wkstitle)

  ; a max of panels, not all used
  npanels = 4
 ; for panels
 if(batch .eq. "yes")then
    ncols = 1
    nrows = 1
 else
    ;ncols = 4
    ;nrows = 1+npanels/ncols
    ;ncols = 2
    ;nrows = 2
    ncols = 1
    nrows = 1
 end if

     plot = new(npanels,graphic)
      dum = new(npanels,graphic)

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  ;res@cnFillMode = "MeshFill"
  res@cnFillMode = "RasterFill"
  res@mpFillOn   = True
  ;res@mpOutlineOn   = False

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnFillDrawOrder   = "PreDraw"             ; draw contours first
  res@cnFillOn           = True                  ; color fill
  res@cnLinesOn          = False                 ; no contour lines
  res@cnLineLabelsOn     = False                 ; no contour lines
  res@lbLabelBarOn       = False                 ; turn off individual colorbars
  res@lbLabelFontHeightF = 0.010

  res@gsnPolar   =  hemi                         ; specify the hemisphere
  if(hemi .eq. "NH")then
   res@mpMinLatF    =  minlat                          ; minimum lat to plot
   res@mpCenterLonF = -45
  end if
  if(hemi .eq. "SH")then
   res@mpMaxLatF    = -50                            ; minimum lat to plot
   res@mpCenterLonF = 0.0
  end if

  if(varname .eq. "aice_h" .or. varname .eq. "aice")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,0.7,0.8,0.85,0.9,0.950/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,0.7,0.8,0.85,0.9,0.950/)+""
  else if(varname .eq. "hi_h" .or. varname .eq. "hi")then
   res@cnLevelSelectionMode        = "ExplicitLevels"
   res@cnLevels                    = (/     0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)
   res@lbLabelStrings              = (/0.00,0.15,0.50,1.0,1.5,2.0,2.5,3.0,3.5,4.0/)+""
  else
   res@cnLevelSelectionMode = "ManualLevels"        ; set the contour levels with the following 3 resources
   res@cnMinLevelValF       = pltlevs(0)            ; set the minimum contour level
   res@cnMaxLevelValF       = pltlevs(1)            ; set the maximum contour level
   res@cnLevelSpacingF      = pltlevs(2)            ; set the interval between contours
  end if
  end if

  res@cnFillPalette   = colormap             ; choose colormap
  res@gsnPolarLabelFontHeightF = .020              ; change font height of labels

  res@tiMainFontHeightF    = 0.01
  res@gsnStringFontHeightF = 0.025
  res@gsnCenterStringFontHeightF = 0.040

;************************************************
; Resources for the polyline
;************************************************

  res@mpGreatCircleLinesOn = True
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness
  pres@gsLineColor      = "black"         ; color of lines
  pres@gsLineDashPattern =  1            ; dashes
  ;pres@tfPolyDrawOrder = "postDraw"

;************************************************
; resources for polymarkers
;************************************************

  mkres               = True
  ;mkres@gsMarkerIndex = 16         ; circle
  mkres@gsMarkerIndex = 15         ; open circle+cross
  ;mkres@gsMarkerIndex = 2         ; cross hair
  mkres@gsMarkerSizeF = 0.020
  mkres@gsMarkerColor = "Red"

;************************************************
; create base plot and a label
;************************************************

              ii = 0
          icevar = icef[ii]->$varname$(0,:,:)
    icevar@lon2d = icef[ii]->$tlonname$*rfactor
    icevar@lat2d = icef[ii]->$tlatname$*rfactor
     labelstring = icevar@long_name+" ("+icevar@units+")  "+"["+varname+"]"
    icevar@units = ""
icevar@long_name = ""

   plot(ii) = gsn_csm_contour_map_polar(wks,icevar(:,:),res)    ; create the plot
    dum(ii) = gsn_add_polyline(wks,plot(ii),(/lon1, lon2/) , (/lat1, lat2/) ,pres)

;************************************************
; loop over files
;************************************************

   do ii = 0,nfiles-1
    if(ii .gt. 0)then
     setvalues plot@data
        "sfDataArray" : icef[ii]->$varname$(0,:,:)
      end setvalues
    end if
   draw(plot)
   frame(wks)
  end do

exit
end
