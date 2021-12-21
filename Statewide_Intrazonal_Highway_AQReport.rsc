Macro "Batch Macro"
RunMacro("TCB Init")
	
// Instructions on using the program. Need to check four things before compling and running the program. 
// Search for the comment "need to be checked" to make appropriate changes. There are four places that need to be checked.
// 1. Check the year defined correctly. 
// 2. Check the project path defined well. For example, ProjectPath = "C:\\Projects\\Statewide\\Model\\" by default
// 3. Check the emission rate file. Make sure to use the right emission rate file. 

// More about the emission rates. There are two sets of emission rate files. For the LRTP work, it applied the 
// emission files following the naming convention as "RatePerDistance_****_MA.bin". There are five years of emission rates, 
// inculding the 2012, 2016, 2020, 2030, and 2040. Recently, MassDOT wanted the near future air quality numbers. 
// Thus we got the 2012, 2018, 2019, and 2020 MOVES emission rates using recent MOVES inputs and RMV data. 
// The file names following the format "EmissionRates_e_w_MA_****.bin"
// The comparison between the previous 2020 and the recent 2020 showed that the recent
// 2020 rates are lower than the previous one. I suggest to use the previous processed rate if the project needs the have air quality numbers 
// after 2020 to make sure the resultant numbers comparable. Otherwise, using the recent generated emission rates.

// Look for the report file following the path :\Projects\Statewide\Model\Reports,after running the program.

// If you still have questions or problems using the program, please talk to Jieping. Good luck!

	
//LRTP Scenarios
//Scen_00: Base 2010
//Scen_01: 2040 NB
//Scen_02: 2020 NB
//Scen_03: 2030 NB
//Scen_04: 2020 BD
//Scen_05: 2030 BD
//Scen_06: 2040 BD
	
	
//*****************************************************************************************************************
//1. need to be checked. Set up the year.	
//*****************************************************************************************************************
	//Year = 2012 //Base
	//Year = 2016 //Base
	//Year = 2020
	//Year = 2030
	Year = 2040   
	//BaseBuild = 1 // no build
	//BaseBuild = 2  //build BaseBuild = 2
	

//*****************************************************************************************************************
//2. need to be checked. Set up the ProjectPath	
//*****************************************************************************************************************
		
	//ProjectPath = "d:\\Projects\\Statewide\\GLX_AQ\\2040NoBuild_noGLX\\"	
	ProjectPath = "d:\\Projects\\Statewide\\GLX_AQ\\2040NoBuild_withGLX\\"

	ProjectPath2 = "d:\\Projects\\Statewide\\GLX_AQ\\"	
		
	AQ_path = "d:\\Projects\\Statewide\\GLX_AQ\\Emission_Factors\\"

//*****************************************************************************************************************
//3. need to be checked. Apply the right emission rates.
//*****************************************************************************************************************
	
//	if Year=2012 then AQ_File = AQ_path +"EmissionRates_e_w_MA_2018.bin"
//	if Year=2012 then AQ_File = AQ_path +"EmissionRates_e_w_MA_2019.bin"
//	if Year=2012 then AQ_File = AQ_path +"EmissionRates_e_w_MA_2020.bin"
	
	if Year=2012 then AQ_File = AQ_path +"RatePerDistance_2012_MA.bin"  //RatePerDistance_2012_MA
	
	if Year=2016 then AQ_File = AQ_path +"RatePerDistance_2016_MA.bin"
	
	if Year=2020 then AQ_File = AQ_path +"RatePerDistance_2020_MA.bin"

	if Year=2030 then AQ_File = AQ_path +"RatePerDistance_2030_MA.bin"
	
	if Year=2040 then AQ_File = AQ_path +"RatePerDistance_2040_MA.bin"
		
	
	SkimFile 		= ProjectPath +"SOV_skim.mtx"
	AM_Tab_File 	= ProjectPath +"AfterSC_Final_AM_Tables.mtx"
	MD_Tab_File 	= ProjectPath +"AfterSC_Final_MD_Tables.mtx"
	PM_Tab_File 	= ProjectPath +"AfterSC_Final_PM_Tables.mtx"
	NT_Tab_File 	= ProjectPath +"AfterSC_Final_NT_Tables.mtx"
	
	Result_File 	= ProjectPath2 + "Tables\\SW_Hwy_AQ_TAZ_Intra.bin"
	Result_vw = RunMacro("TCB OpenTable",,, {Result_File})
	
	sorter = {{"Sort Order", {{"ID", "Ascending"}}}}

	
	{ID, EMass_Flag, Intra_VMT, Intra_VHT, Intra_Auto_VMT, Intra_Auto_VHT, Intra_TRK_VMT, Intra_TRK_VHT, Intra_CO, Intra_NOX, Intra_VOC, Intra_CO2}
		= GetDataVectors(Result_vw+"|", {"ID", "EMass_Flag", "Intra_VMT", "Intra_VHT", "Intra_Auto_VMT", "Intra_Auto_VHT", "Intra_TRK_VMT", "Intra_TRK_VHT", "Intra_CO", 
		"Intra_NOX", "Intra_VOC", "Intra_CO2"}, sorter)	  //"LU_Type"

	Tabs = {AM_Tab_File, MD_Tab_File, PM_Tab_File, NT_Tab_File}
	
	skim_mtx	= OpenMatrix(SkimFile, "TRUE") 
	
	CongTime_mc = CreateMatrixCurrency(skim_mtx, "CongTime_wTerminalTimes",,,)			
	Length_mc = CreateMatrixCurrency(skim_mtx, "Length (Skim)",,,)		
	
	V_CongTime = GetMatrixVector(CongTime_mc,  {{"Diagonal", "Row"}})
	V_Length = GetMatrixVector(Length_mc,  {{"Diagonal", "Row"}})
	
	row_labels = GetMatrixRowLabels(CongTime_mc)

//showmessage("hello1")	
	
	Dim Temp[V_CongTime.length]
	
	V_Auto_VMT = A2V(Temp)
	V_Truck_VMT = A2V(Temp)		
	V_Auto_VHT = A2V(Temp)
	V_Truck_VHT = A2V(Temp)
	
	for i=1 to Tabs.length do 
		trips_mtx	= OpenMatrix(Tabs[i], "TRUE") 
		SOV_mc = CreateMatrixCurrency(trips_mtx, "SOV",,,)	
		HOV2p_mc = CreateMatrixCurrency(trips_mtx, "HOV2p",,,)
		HOV3p_mc = CreateMatrixCurrency(trips_mtx, "HOV3p",,,)
		
		DAT_Boat_mc = CreateMatrixCurrency(trips_mtx, "DAT_Boat",,,)
		DAT_LB_mc = CreateMatrixCurrency(trips_mtx, "DAT_LB",,,)
		DAT_RT_mc = CreateMatrixCurrency(trips_mtx, "DAT_RT",,,)
		DAT_CR_mc = CreateMatrixCurrency(trips_mtx, "DAT_CR",,,)
		
		DET_Boat_mc = CreateMatrixCurrency(trips_mtx, "DET_Boat",,,)
		DET_LB_mc = CreateMatrixCurrency(trips_mtx, "DET_LB",,,)
		DET_RT_mc = CreateMatrixCurrency(trips_mtx, "DET_RT",,,)
		DET_CR_mc = CreateMatrixCurrency(trips_mtx, "DET_CR",,,)
		
		LT_mc = CreateMatrixCurrency(trips_mtx, "Light_Truck",,,)		
		MT_mc = CreateMatrixCurrency(trips_mtx, "Medium_Truck",,,)		
		HT_mc = CreateMatrixCurrency(trips_mtx, "Heavy_Truck",,,)	
	
		V_SOV = GetMatrixVector(SOV_mc,  {{"Diagnol", "Row"}})   //trips
		V_HOV2p = GetMatrixVector(HOV2p_mc,  {{"Diagnol", "Row"}}) 
		V_HOV3p = GetMatrixVector(HOV3p_mc,  {{"Diagnol", "Row"}}) 
		
		V_DAT_Boat = GetMatrixVector(DAT_Boat_mc,  {{"Diagnol", "Row"}}) 
		V_DAT_LB = GetMatrixVector(DAT_LB_mc,  {{"Diagnol", "Row"}}) 		
		V_DAT_RT = GetMatrixVector(DAT_RT_mc,  {{"Diagnol", "Row"}}) 
		V_DAT_CR = GetMatrixVector(DAT_CR_mc,  {{"Diagnol", "Row"}}) 

		V_DET_Boat = GetMatrixVector(DET_Boat_mc,  {{"Diagnol", "Row"}}) 
		V_DET_LB = GetMatrixVector(DET_LB_mc,  {{"Diagnol", "Row"}}) 		
		V_DET_RT = GetMatrixVector(DET_RT_mc,  {{"Diagnol", "Row"}}) 
		V_DET_CR = GetMatrixVector(DET_CR_mc,  {{"Diagnol", "Row"}}) 	
		
		
		V_LT = GetMatrixVector(LT_mc,  {{"Diagnol", "Row"}})
		V_MT = GetMatrixVector(LT_mc,  {{"Diagnol", "Row"}})
		V_HT = GetMatrixVector(LT_mc,  {{"Diagnol", "Row"}})
	
		V_Auto_VMT = nz(V_Auto_VMT) + (V_Length * (V_SOV+V_HOV2p+V_HOV3p+V_DAT_Boat+V_DAT_LB+V_DAT_RT+V_DAT_CR+V_DET_Boat+V_DET_LB+V_DET_RT+V_DET_CR ))    //daily VMT
		V_Truck_VMT = nz(V_Truck_VMT) + (V_Length * ( V_LT + V_MT + V_HT  ))
		
		V_Auto_VHT = nz(V_Auto_VHT) + ((V_CongTime/60) * (V_SOV+V_HOV2p+V_HOV3p+V_DAT_Boat+V_DAT_LB+V_DAT_RT+V_DAT_CR+V_DET_Boat+V_DET_LB+V_DET_RT+V_DET_CR ))
		V_Truck_VHT = NZ(V_Truck_VHT) + ((V_CongTime/60) * ( V_LT + V_MT + V_HT  ))
		
	end
	
	For i=1 to V_SOV.length do   // V_SOV.length=5839
		//row = s2i(row_labels[i])
		Intra_VMT [i] = V_Auto_VMT[i] + V_Truck_VMT[i]
		Intra_VHT [i] = V_Auto_VHT[i] + V_Truck_VHT[i]
		Intra_Auto_VMT [i] = V_Auto_VMT[i]
		Intra_Auto_VHT [i] = V_Auto_VHT[i]
		Intra_TRK_VMT [i] = V_Truck_VMT[i]
		Intra_TRK_VHT [i] = V_Truck_VHT[i]		
	end

	SetDataVectors(Result_vw +"|", {
				{"Intra_VMT",Intra_VMT},{ "Intra_VHT",Intra_VHT}, {"Intra_Auto_VMT",Intra_Auto_VMT},{"Intra_Auto_VHT",Intra_Auto_VHT},
				{"Intra_TRK_VMT",Intra_TRK_VMT},{"Intra_TRK_VHT",Intra_TRK_VHT}}, {{"Sort Order", {{"ID", "Ascending"} }}})
	
//showmessage("hello2")
			
	// Calculate air quality emissions 
	AQ_EmsnFac_VW=RunMacro("TCB OpenTable",,,{AQ_File})	
	//showmessage("AQ_File is: "+AQ_File)
	//showmessage("AQ_EmsnFac_VW is:"+AQ_EmsnFac_VW)
	OK = (AQ_EmsnFac_VW<>null) if !OK then do ok=0 goto quit end
		
	{V_SpeedID,V_EMass,V_Month,V_TOD,V_VehType,V_RoadType,V_CO,V_NOX, V_VOC, V_CO2, V_PM10,V_PM25} = GetDataVectors(AQ_EmsnFac_VW + "|", 
		{"avgSpeedBinID", "EMASS", "MonthID","periodID","vehicleTypeID","roadTypeID","CO", "NOX", "VOC", "CO2","PM10", "PM25"},)
				
		Dim CO_Tab[2,12,4,2,4,16], NOX_Tab[2,12,4,2,4,16], VOC_Tab[2,12,4,2,4,16], CO2_Tab[2,12,4,2,4,16], PM10_Tab[2,12,4,2,4,16], PM25_Tab[2,12,4,2,4,16]	
		
		for i=1 to V_SpeedID.length do
			CO_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_CO[i]
			NOX_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_NOX[i]
			VOC_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_VOC[i]
			CO2_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_CO2[i]
			PM25_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_PM25[i]
			PM10_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_PM10[i]
		//if i=1 then showarray(CO_Tab)	
		end
		
		for i=1 to V_SOV.length do   // V_Auto.length=5839
		if EMass_Flag[i]=null then continue
		
		
			if (V_CongTime[i])>0 then do
				ave_spd = (V_Length[i] / V_CongTime[i])*60
				if ave_spd < 72.5 then spdID = r2i((ave_spd+2.5)/5)+1 else spdID = 16
				end
			else do
				ave_spd = 0
				spdID =1
				end
		
			/*	if V_LU =1 then rdID=3 else rdID=1    // rdID=3 urban restricted  rdID=1 rurual restricted
				end
			else do
				if V_LU=1 then rdID=4 else rdID=2	 // rdID=4 urban unrestricted  rdID=2 rurual unrestricted
				end*/
		
		rdID=1
			month=1 pd=1
			Intra_NOX[i]=nz(Intra_Auto_VMT[i])*NOX_Tab[EMass_Flag[i]][month][pd][1][rdID][spdID]+  nz(Intra_TRK_VMT[i])*NOX_Tab[EMass_Flag[i]][month][pd][2][rdID][spdID]
						
			month=7 pd=1
						
			Intra_VOC[i]=nz(Intra_Auto_VMT[i])*VOC_Tab[EMass_Flag[i]][month][pd][1][rdID][spdID] + nz(Intra_TRK_VMT[i])*VOC_Tab[EMass_Flag[i]][month][pd][2][rdID][spdID]
						
			Intra_CO2[i]=nz(Intra_Auto_VMT[i])*CO2_Tab[EMass_Flag[i]][month][pd][1][rdID][spdID]+  nz(Intra_TRK_VMT[i])*CO2_Tab[EMass_Flag[i]][month][pd][2][rdID][spdID]

			Intra_CO[i]=nz(Intra_Auto_VMT[i])*CO_Tab[EMass_Flag[i]][month][pd][1][rdID][spdID]  + nz(Intra_TRK_VMT[i])*CO_Tab[EMass_Flag[i]][month][pd][2][rdID][spdID]
			
			end 
	
/*	
		SetDataVectors(Result_vw +"|", {
				{"Intra_VMT",Intra_VMT},{ "Intra_VHT",Intra_VHT}, {"Intra_Auto_VMT",Intra_Auto_VMT},{"Intra_Auto_VHT",Intra_Auto_VHT},
				{"Intra_TRK_VMT",Intra_TRK_VMT},{"Intra_TRK_VHT",Intra_TRK_VHT},
				{ "Intra_VOC",Intra_VOC},{ "Intra_NOX",Intra_NOX}, { "Intra_CO",Intra_CO},
				{ "Intra_CO2",Intra_CO2}},{{"Sort Order", {{"ID", "Ascending"}  }}})
*/			
//showmessage("hello3")	
				
	//writing results into the report
Report_file	= ProjectPath2 + "Reports\\Statewide_AQ_IntraZonal.txt"		
		
	date = GetDateAndTime()
		
	sp=SplitPath(Report_file)
	
	
	Highway_Air_Quality_Report = ProjectPath2 + "Reports\\"+"Statewide_IntraZonal_Highway_Air_Quality_by_Community" +".txt"
	rpt = OpenFile(Highway_Air_Quality_Report,"w")

//AQ_area = {"BRPC","CCC","CMRPC","FRCOG","MAPC","MRPC","MVC","MVPC","NMCOG","NPEDC","OCPC","PVPC","SRPEDD","Suffolk MA", "Middlesex MA","Norfolk MA","Essex MA","Plymouth MA","Worcester MA","Bristol MA","Barnstable MA","Dukes //MA","Nantucket MA","Hampden MA","Hampshire MA","Franklin MA","Berkshire MA"}
	
	
 //AQ_area = {"BRPC","CCC","CMRPC","FRCOG","MAPC","MAPC/OCPC","MRPC","MVC","MVPC","NMCOG","NPEDC","OCPC","PVPC","SRPEDD","Boston", "Cambridge", "Chelsea", "Everett", "Malden", "Medford", "Quincy","Revere", "Somerville", //"Waltham"}  //
// AQ_area = {"EMass", "MPO"}

AQ_area = {"BRPC","CCC","CMRPC","FRCOG","MAPC","MRPC","MVC","MVPC","NMCOG","NPEDC","OCPC","PVPC","SRPEDD","FourTowns","Suffolk MA", "Middlesex MA","Norfolk MA","Essex MA","Plymouth MA","Worcester MA","Bristol MA","Barnstable MA","Dukes MA","Nantucket MA","Hampden MA","Hampshire MA","Franklin MA","Berkshire MA"}

  
 Len_AQ=AQ_area.length
 	
 	outline=null pad=12
 	
 	Dim AQ_V_VMT[AQ_area.length], AQ_V_VHT[AQ_area.length], AQ_V_AutoVMT[AQ_area.length], AQ_V_AutoVHT[AQ_area.length], AQ_V_TRKVMT[AQ_area.length], AQ_V_TRKVHT[AQ_area.length], 
	AQ_V_VOC [AQ_area.length], AQ_V_NOx[AQ_area.length], AQ_V_CO[AQ_area.length],AQ_V_CO2[AQ_area.length]
	
	Writeline(rpt,"Highway Air Quality Report: "+date)
	if BaseBuild=1 then BaseBuild=No-Build
	if BaseBuild=2 then BaseBuild=Build
	Writeline(rpt,I2s(Year))
	//Writeline(rpt, BaseBuild)
	
 	
 		Writeline(rpt,"")
		Writeline(rpt,"") Writeline(rpt,"")
		Writeline(rpt,"********************************************************************************************************************************************************")
		Writeline(rpt,"Summary of Statewide Daily IntraZonal Highway Air Quality ")
		Writeline(rpt,"********************************************************************************************************************************************************")
		Writeline(rpt,"")
		Writeline(rpt,"                VMT(mi)       VHT(hr)    AutoVMT(mi)    AutoVHT(hr)   TRKVMT(mi)  TRKVHT(hr)      VOC-s(kg)     NOx-s(kg)      CO-w(kg)     CO2-s(kg)  ")	
		Writeline(rpt,"----------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- -------------")	
 
 		for aq=1 to AQ_area.length do
  			SetView(Result_vw)
 			
 			if aq<15 then do  //Non-MAPC Area
				query = "Select* where RPA_2='"+AQ_area[aq]+"'"
				AreaSummary = SelectByQuery("AreaSummary_EMass", "Several", query,)
				{V_VMT,V_VHT,V_AutoVMT,V_AutoVHT,V_TRKVMT,V_TRKVHT,V_VOC,V_NOx, V_CO, V_CO2} 
				= GetDataVectors(Result_vw + "|AreaSummary_EMass",{"Intra_VMT","Intra_VHT",
				"Intra_Auto_VMT","Intra_Auto_VHT","Intra_TRK_VMT","Intra_TRK_VHT",
				"Intra_VOC","Intra_NOX","Intra_CO", "Intra_CO2"}, )

				AQ_V_VMT[aq]  = VectorStatistic(V_VMT, "Sum", ) 
				AQ_V_VHT[aq]  = VectorStatistic(V_VHT, "Sum", ) 
				AQ_V_AutoVMT[aq]  = VectorStatistic(V_AutoVMT, "Sum", ) 
				AQ_V_AutoVHT[aq]  = VectorStatistic(V_AutoVHT, "Sum", ) 
	
				AQ_V_TRKVMT[aq]  = VectorStatistic(V_TRKVMT, "Sum", ) 
				AQ_V_TRKVHT[aq]  = VectorStatistic(V_TRKVHT, "Sum", ) 
				AQ_V_VOC[aq]  = VectorStatistic(V_VOC, "Sum", ) 
				AQ_V_NOx[aq]  = VectorStatistic(V_NOx, "Sum", ) 
				AQ_V_CO[aq]   = VectorStatistic(V_CO, "Sum", ) 
				AQ_V_CO2[aq]  = VectorStatistic(V_CO2, "Sum", ) 
	
			end


				else do  //Selected Cities
					query = "Select* where County='"+AQ_area[aq]+"'"
					AreaSummary = SelectByQuery("AreaSummary_"+AQ_area[aq], "Several", query,)
					{V_VMT,V_VHT,V_AutoVMT,V_AutoVHT,V_TRKVMT,V_TRKVHT,V_VOC,V_NOx, V_CO, V_CO2} 
					= GetDataVectors(Result_vw + "|AreaSummary_"+AQ_area[aq],{"Intra_VMT","Intra_VHT",
				"Intra_Auto_VMT","Intra_Auto_VHT","Intra_TRK_VMT","Intra_TRK_VHT",
				"Intra_VOC","Intra_NOX","Intra_CO", "Intra_CO2"}, )

					AQ_V_VMT[aq]  = VectorStatistic(V_VMT, "Sum", ) 
					AQ_V_VHT[aq]  = VectorStatistic(V_VHT, "Sum", ) 
        			AQ_V_AutoVMT[aq]  = VectorStatistic(V_AutoVMT, "Sum", ) 
        			AQ_V_AutoVHT[aq]  = VectorStatistic(V_AutoVHT, "Sum", ) 
      
        			AQ_V_TRKVMT[aq]  = VectorStatistic(V_TRKVMT, "Sum", ) 
        			AQ_V_TRKVHT[aq]  = VectorStatistic(V_TRKVHT, "Sum", ) 
					AQ_V_VOC[aq]  = VectorStatistic(V_VOC, "Sum", ) 
					AQ_V_NOx[aq]  = VectorStatistic(V_NOx, "Sum", ) 
					AQ_V_CO[aq]   = VectorStatistic(V_CO, "Sum", ) 
					AQ_V_CO2[aq]  = VectorStatistic(V_CO2, "Sum", ) 
		
				end	

  			// pad +1, add one extra space for the blank between numbers
			S1= Format(r2i(AQ_V_VMT[aq] *1),"*,")				L=len(S1) for K=L+1 to pad+1 do S1 = ' '+S1 end
			S2= Format(r2i(AQ_V_VHT[aq] *1),"*,")				L=len(S2) for K=L+1 to pad+1 do S2 = ' '+S2 end
			S3= Format(r2i(AQ_V_AutoVMT[aq] *1),"*,")			L=len(S3) for K=L+1 to pad+1 do S3 = ' '+S3 end
			S4= Format(r2i(AQ_V_AutoVHT[aq] *1),"*,")			L=len(S4) for K=L+1 to pad+1 do S4 = ' '+S4 end
		
			S7= Format(r2i(AQ_V_TRKVMT[aq] *1),"*,")			L=len(S7) for K=L+1 to pad+1 do S7 = ' '+S7 end
			S8= Format(r2i(AQ_V_TRKVHT[aq] *1),"*,")			L=len(S8) for K=L+1 to pad+1 do S8 = ' '+S8 end
			S9= Format(r2i(AQ_V_VOC[aq] ),"*,")			L=len(S9) for K=L+1 to pad+1 do S9 = ' '+S9 end	
			S10= Format(r2i(AQ_V_NOx[aq]),"*,")			L=len(S10) for K=L+1 to pad+1 do S10 = ' '+S10 end	
			S11= Format(r2i(AQ_V_CO[aq] ),"*,")			L=len(S11) for K=L+1 to pad+1 do S11 = ' '+S11 end 	
			S12= Format(r2i(AQ_V_CO2[aq] ),"*,")			L=len(S12) for K=L+1 to pad+1 do S12 = ' '+S12 end	
	

			Sname=AQ_area[aq]  L=len(Sname) for K=L+1 to pad do Sname = Sname+' ' end
			outline= S1 + S2 + S3 + S4 + S7 + S8 + S9 + S10 + S11+ S12 
			WriteLine(rpt, Sname+outline) 			
 		end  //for aq=1 to AQ_area.length do
 
 		Writeline(rpt,"----------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- -------------")	
		


	ShowMessage("Statewide Highway AQ Finished.") 			
				
				
    quit:
	ok=1
    Return( RunMacro("TCB Closing", ok, True ) )
endMacro
