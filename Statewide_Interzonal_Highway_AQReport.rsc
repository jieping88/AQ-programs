Macro "Batch Macro"
RunMacro("TCB Init")
	
// Instructions on using the program. Need to check four things before compling and running the program. 
// Search for the comment "need to be checked" to make appropriate changes. There are four places that need to be checked.
// 1. Check the year and scenario defined correctly. For example, if your model run is 2016 and this is identified as Scen_00 in the scenario 
// manager, you should make the year be 2016  and pre="Scen_00". 
// 2. Check the project path defined well. For example, ProjectPath = "C:\\Projects\\Statewide\\Model\\" by default
// 3. Check the emission rate file. Make sure to use the right emission rate file. 
// 4. Check the link selection sets. Make sure the selection sets are the same as the pre="Scen_00".

// About the emission rates. There are two sets of emission rate files. For the LRTP work, it applied the 
// emission files following the naming convention as "RatePerDistance_****_MA.bin". There are six years of emission rates, 
// inculding the 2012, 2016, 2018, 2020, 2030, and 2040. RatePerDistance_2018_MA is derived from RatePerDistance_2016_MA and RatePerDistance_2020_MA emission rates. Recently, MassDOT 
// requested the recent future air quality numbers. Thus we got the 2012, 2018, 2019, and 2020 MOVES emission rates using recent MOVES inputs and RMV data. 
// The file names following the format "EmissionRates_e_w_MA_****.bin" The comparison between the previous 2020 and the recent 2020 showed the later are lower than the former. 
// I suggest to use the previous processed rates if the project needs the air quality numbers after 2020 to make sure the resultant numbers comparable. 

// If you still have questions or problems using the program, please talk to Jieping. Good luck!


// Greenline extension project AQ/emissions to be done for the following folders on machine 8

//Projects\statewide\out_LRTP_2040_No Build\Input_Archive\Databases

//Projects\statewide\out_LRTP_2040 No Build without GLX\Input_Archive\Databases


//*****************************************************************************************************************
//1. need to be checked. Set up the scenario	
//*****************************************************************************************************************
	 
	Year = 2040
	//BaseBuild = 1 // no build
	//BaseBuild = 2  //build 
	pre="Scen_01"
	
//*****************************************************************************************************************
//2. need to be checked when running the program. Set up the ProjectPath	
//*****************************************************************************************************************
	
	ProjectPath = "d:\\Projects\\Statewide\\GLX_AQ\\"	  		 		// Databases_LRTP_March
	
		                                                                              
	ProjectPath2 = "d:\\Projects\\Statewide\\GLX_AQ\\2040NoBuild_withGLX\\Databases_200iter\\"    	//Projects\statewide\out_LRTP_2040_No Build\Input_Archive\Databases    D:\Projects\Statewide\GLX_AQ\2040NoBuild_withGLX
	                                                                             
	//ProjectPath2 = "d:\\Projects\\Statewide\\GLX_AQ\\2040NoBuild_noGLX\\Databases_200iter\\"    	//Projects\statewide\out_LRTP_2040 No Build without GLX\Input_Archive\Databases
	
	//Inputs	
	Links_db_file = ProjectPath2 + "Statewide_Links_2018.dbd"
			
	AQ_path = ProjectPath + "Emission_Factors\\"	   //D:\Projects\Statewide\Model\Emission_Factors
		
	SW_Hwy_AQ_Tab = ProjectPath + "Tables\\SW_Hwy_AQ_MAPC_Interzonal.bin"    			
	
	{node_lyr, link_lyr} = RunMacro("TCB Add DB Layers", Links_db_file,,)
	SetView(link_lyr)	

	
//*****************************************************************************************************************
//3. need to be checked. Apply the right emission rates.
//*****************************************************************************************************************

//	if Year=2012 then AQ_File = AQ_path +"RatePerDistance_2012_MA.bin"	  //old emission rates

	if Year=2016 then AQ_File = AQ_path +"RatePerDistance_2016_MA.bin"	
	
	if Year=2018 then AQ_File = AQ_path +"RatePerDistance_2018_MA.bin"
		
	if Year=2020 then AQ_File = AQ_path +"RatePerDistance_2020_MA.bin"	

	if Year=2030 then AQ_File = AQ_path +"RatePerDistance_2030_MA.bin"
	
	if Year=2040 then AQ_File = AQ_path +"RatePerDistance_2040_MA.bin"   //RatePerDistance_2040_MA.bin

	
if getfileinfo(AQ_File)=null then showmessage("Missing emission rate file!")
	
//*****************************************************************************************************************
//4. need to be checked. Check the link selection sets.
//*****************************************************************************************************************
	
	n =	SelectByQuery ("InModel","Several","Select *  where Scen_01=1 & In_MPO = 1",)       		// select MPO area in 2040 no build
			{V_ID,V_Dir,V_Length,V_FC,V_LU}=
				GetDataVectors(link_lyr + "|InModel", 
				{"ID", "Dir","Length",pre+"_FuncClass","URBANCODE"}, {{"Sort Order", {{"ID", "Ascending"}  }}})	//{{"Sort Order", {{"ID", "Ascending"}  }}}			 
	 
  		
	{node_lyr, link_lyr} = RunMacro("TCB Add DB Layers", Links_db_file,,)        	
//	TAZlayers = RunMacro("TCB Add DB Layers", TAZ_db_file)   
	//ShowArray(TAZlayers)
//	TAZlyr   = TAZlayers[1]
//	TAZlyr_set = TAZlyr+"|"	
//	{V_TAZ_ID}=GetDataVectors(TAZlyr + "|", {"ID"},)
//	count_TAZ =V_TAZ_ID.length

			
	// Load the MOVES emission factors lookup tables
	// =======================================
	
		// [EMass WMass 1-2][month 1-2]	[time period 1-4 ]  [vehicle type 1-2]  [road type 2-5] [speed index 1-16]   2*4*2*4*16=1024  
		Dim CO_Tab[2,12,4,2,4,16], NOX_Tab[2,12,4,2,4,16], VOC_Tab[2,12,4,2,4,16], CO2_Tab[2,12,4,2,4,16], PM10_Tab[2,12,4,2,4,16], PM25_Tab[2,12,4,2,4,16]
		//AQ_EmsnFac_VW=RunMacro("TCB OpenTable",,,{AQ_File_EM})	
		//ok = (AQ_EmsnFac_VW<>null) if !OK then do ok=0 goto quit end
	
	
	// Calculate air quality emissions 
	AQ_EmsnFac_VW=RunMacro("TCB OpenTable",,,{AQ_File})	
	//showmessage("AQ_File is: "+AQ_File)
	//showmessage("AQ_EmsnFac_VW is:"+AQ_EmsnFac_VW)
	OK = (AQ_EmsnFac_VW<>null) if !OK then do ok=0 goto quit end
		
		{V_SpeedID,V_EMass,V_Month,V_TOD,V_VehType,V_RoadType,V_CO,V_NOX, V_VOC, V_CO2, V_PM10,V_PM25} = GetDataVectors(AQ_EmsnFac_VW + "|", 
		{"avgSpeedBinID", "EMass", "MonthID","periodID","vehicleTypeID","roadTypeID","CO", "NOX", "VOC", "CO2","PM10", "PM25"},)
		
		for i=1 to V_SpeedID.length do
			CO_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_CO[i]
			NOX_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_NOX[i]
			VOC_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_VOC[i]
			CO2_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_CO2[i]
			PM25_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_PM25[i]
			PM10_Tab[V_EMass[i]][V_Month[i]][V_TOD[i]][V_VehType[i]][V_RoadType[i]-1][V_SpeedID[i]] = V_PM10[i]
		//if i=1 then showarray(CO_Tab)
		
		end
		
	count_link = V_ID.length 
	prd = {"AM", "MD", "PM", "NT","Dly"}
	count_period = prd.length 	
	
//showmessage("hello1")	
// Period is the first dimension and link is the second dimension. The row value will be link values for each period. This way, it is easy to convert the array into a vector. Calculate the individual link level air quality, then aggregate the results into TAZ
	Dim V_VMT[count_period,count_link],V_VHT[count_period,count_link],V_Auto_VMT[count_period,count_link],V_Auto_VHT[count_period,count_link],
	V_TRK_VMT[count_period,count_link], V_TRK_VHT[count_period,count_link],
	V_CO [count_period,count_link], V_NOX[count_period,count_link],V_VOC[count_period,count_link],V_CO2[count_period,count_link],V_PM25[count_period,count_link],V_PM10[count_period,count_link]
	
	max_TownID=1  //max_TownID=360
	Dim V_T_VMT[count_period,max_TownID],V_T_VHT[count_period,max_TownID], V_T_Auto_VMT[count_period,max_TownID],V_T_Auto_VHT[count_period,max_TownID],
	V_T_TRK_VMT[count_period,max_TownID], V_T_TRK_VHT[count_period,max_TownID],
	V_T_CO[count_period,max_TownID], V_T_NOX[count_period,max_TownID], V_T_VOC[count_period,max_TownID],V_T_CO2[count_period,max_TownID] ,  V_T_PM25[count_period,max_TownID],V_T_PM10[count_period,max_TownID] , T_PD_LinkCount[count_period,max_TownID] //JPL
	
	for pd=1 to count_period do
		for j=1 to max_TownID do
			V_T_VMT[pd][j] = 0
			V_T_VHT[pd][j] = 0		
			V_T_Auto_VMT[pd][j] = 0
			V_T_Auto_VHT[pd][j] = 0
			V_T_TRK_VMT[pd][j] = 0
			V_T_TRK_VHT[pd][j] = 0
			V_T_CO[pd][j] = 0
			V_T_NOX[pd][j] = 0
			V_T_VOC[pd][j] = 0
			V_T_CO2[pd][j] = 0	
			V_T_PM25[pd][j] = 0
			V_T_PM10[pd][j] = 0						
			T_PD_LinkCount[pd][j] = 0 //JPL
			end		
		for i=1 to count_link do
			V_VMT[pd][i] = 0
			V_VHT[pd][i] = 0		
			V_Auto_VMT[pd][i] = 0
			V_Auto_VHT[pd][i] = 0
			V_TRK_VMT[pd][i] = 0
			V_TRK_VHT[pd][i] = 0		
			V_CO[pd][i] = 0
			V_NOX[pd][i] = 0
			V_VOC[pd][i] = 0
			V_CO2[pd][i] = 0
			V_PM25[pd][i] = 0
			V_PM10[pd][i] = 0				
			end			
		end
		
	//Scen_00_AB_AM_CongTime
	 for pd=1 to count_period -1 do
 		{V_ID, Auto_AB, Auto_BA, V_total_AB,V_total_BA, AB_CongTime, BA_CongTime, 
			AB_SOV,BA_SOV, AB_HOV,BA_HOV,AB_DAT,BA_DAT,AB_DET,BA_DET,
			AB_PUV,BA_PUV,AB_TRK,BA_TRK,AB_HAZ,BA_HAZ,
			AB_Med_HazMat,BA_Med_HazMat,AB_Hvy_HazMat,BA_Hvy_HazMat,
			EMass}		 	
			=GetDataVectors(link_lyr + "|InModel", {"ID", "AB_"+prd[pd]+"_Total","BA_"+prd[pd]+"_Total", "AB_"+prd[pd]+"_Total","BA_"+prd[pd]+"_Total",
			pre+"_AB_"+prd[pd]+"_CongTime", pre+"_BA_"+prd[pd]+"_CongTime",                                                          //			"AB_"+prd[pd]+"_CongTime",
			"AB_"+prd[pd]+"_SOV","BA_"+prd[pd]+"_SOV", "AB_"+prd[pd]+"_HOV","BA_"+prd[pd]+"_HOV",
			"AB_"+prd[pd]+"_DAT","BA_"+prd[pd]+"_DAT",
			"AB_"+prd[pd]+"_DET","BA_"+prd[pd]+"_DET",
			"AB_"+prd[pd]+"_LightTruck", "BA_"+prd[pd]+"_LightTruck",
			"AB_"+prd[pd]+"_MediumTruck", "BA_"+prd[pd]+"_MediumTruck",
			"AB_"+prd[pd]+"_HeavyTruck", "BA_"+prd[pd]+"_HeavyTruck",
			"AB_"+prd[pd]+"_MediumTruck_HazMat", "BA_"+prd[pd]+"_MediumTruck_HazMat",
			"AB_"+prd[pd]+"_HeavyTruck_HazMat", "BA_"+prd[pd]+"_HeavyTruck_HazMat",
			"EMass"}, {{"Sort Order", {{"ID", "Ascending"}  }}}) 
		
		for i=1 to count_link do
		if EMass[i]=0 or EMass[i]=null then  EMass[i]=2
		//if EMass[i]=null then continue 
				Auto_AB[i]= nz(AB_SOV[i]) + nz(AB_HOV[i]) + nz(AB_DAT[i]) + nz(AB_DET[i])
				Auto_BA[i]= nz(BA_SOV[i]) + nz(BA_HOV[i]) + nz(BA_DAT[i]) + nz(BA_DET[i])
				
				V_Auto_VMT[pd][i]= (nz(Auto_AB[i])+nz(Auto_BA[i]))* V_Length[i]
				V_Auto_VHT[pd][i]= ((nz(AB_CongTime[i])*nz(Auto_AB[i])) + (nz(BA_CongTime[i])*nz(Auto_BA[i])))/60

				V_TRK_VMT[pd][i]= (nz(AB_PUV[i])+nz(BA_PUV[i])+nz(AB_TRK[i])+nz(BA_TRK[i]) +nz(AB_HAZ[i])+nz(BA_HAZ[i])
				+nz(AB_Med_HazMat[i])+ nz(BA_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i])+ nz(BA_Hvy_HazMat[i]))* V_Length[i]  
				
				V_TRK_VHT[pd][i]= (nz(AB_CongTime[i])*(nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i])))/60 +    
								  (nz(BA_CongTime[i])*(nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i])))/60	   

	//			V_VMT[pd][i] = nz(V_Auto_VMT[pd][i]) + nz(V_TRK_VMT[pd][i])
				
				V_VMT[pd][i] = (nz(V_total_AB[i]) + nz(V_total_BA[i]))*V_Length[i]
				
		//		V_VHT[pd][i] = nz(V_Auto_VHT[pd][i]) + nz(V_TRK_VHT[pd][i])
	
				V_VHT[pd][i] = ((nz(AB_CongTime[i])*nz(V_total_AB[i])) + (nz(BA_CongTime[i])*nz(V_total_BA[i])))/60
					  
			
			if nz(AB_CongTime[i])>0 then do
				AB_spd = (V_Length[i] / AB_CongTime[i])*60
				if AB_spd < 72.5 then AB_spdID = r2i((AB_spd+2.5)/5)+1 else AB_spdID = 16
				end
			else do
				AB_spd = 0
				AB_spdID =1
				end
			if nz(BA_CongTime[i])>0 then do
				BA_spd = (V_Length[i] / BA_CongTime[i])*60
				if BA_spd <72.5 then BA_spdID = r2i((BA_spd+2.5)/5)+1 else BA_spdID = 16
				end
			else do
				BA_spd = 0
				BA_spdID =1
				end			
			if V_FC[i]=1 or V_FC[i]=2 or  (V_FC[i]>49 and V_FC[i]<70) or (V_FC[i]>71 and V_FC[i]<100) then do
				
				if V_LU =1 then rdID=3 else rdID=1    // rdID=3 urban restricted  rdID=1 rurual restricted
			end
			else do
				if V_LU=1 then rdID=4 else rdID=2	 // rdID=4 urban unrestricted  rdID=2 rurual unrestricted
			end
				
			month=7  // month=7
			V_CO[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*CO_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] +
						(nz(Auto_BA[i]))*V_Length[i]*CO_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						(nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*CO_Tab[EMass[i]][month][pd][2][rdID][AB_spdID]+
						(nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*CO_Tab[EMass[i]][month][pd][2][rdID][BA_spdID]
						
			month=1 // month=1
			V_NOX[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*NOX_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] + 
						 (nz(Auto_BA[i]))*V_Length[i]*NOX_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						 (nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*NOX_Tab[EMass[i]][month][pd][1][rdID][AB_spdID]+
						 (nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*NOX_Tab[EMass[i]][month][pd][1][rdID][BA_spdID]

			month=7	// month=7		
			V_VOC[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*VOC_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] +
						 (nz(Auto_BA[i]))*V_Length[i]*VOC_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						 (nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*VOC_Tab[EMass[i]][month][pd][1][rdID][AB_spdID]+
						 (nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*VOC_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] 								
			month=7	 // month=7			
			V_CO2[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*CO2_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] + 
						 (nz(Auto_BA[i]))*V_Length[i]*CO2_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						 (nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*CO2_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] +
						 (nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*CO2_Tab[EMass[i]][month][pd][1][rdID][BA_spdID]

			month=7 // month=7
			V_PM25[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*PM25_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] + 
						  (nz(Auto_BA[i]))*V_Length[i]*PM25_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						  (nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*PM25_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] +
						  (nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*PM25_Tab[EMass[i]][month][pd][1][rdID][BA_spdID]

			month=7 // month=7
			V_PM10[pd][i]=(nz(Auto_AB[i]))*V_Length[i]*PM10_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] + 
						  (nz(Auto_BA[i]))*V_Length[i]*PM10_Tab[EMass[i]][month][pd][1][rdID][BA_spdID] +
						  (nz(AB_PUV[i])+nz(AB_TRK[i])+nz(AB_HAZ[i])+nz(AB_Med_HazMat[i]) + nz(AB_Hvy_HazMat[i]))*V_Length[i]*PM10_Tab[EMass[i]][month][pd][1][rdID][AB_spdID] +
						  (nz(BA_PUV[i])+nz(BA_TRK[i])+nz(BA_HAZ[i])+nz(BA_Med_HazMat[i]) + nz(BA_Hvy_HazMat[i]))*V_Length[i]*PM10_Tab[EMass[i]][month][pd][1][rdID][BA_spdID]
				

	// calculate daily link attributes
			V_VMT[5][i]=nz(V_VMT[5][i])+nz(V_VMT[pd][i])
			V_VHT[5][i]=nz(V_VHT[5][i])+nz(V_VHT[pd][i])
			V_Auto_VMT[5][i]=nz(V_Auto_VMT[5][i])+nz(V_Auto_VMT[pd][i])
			V_Auto_VHT[5][i]=nz(V_Auto_VHT[5][i])+nz(V_Auto_VHT[pd][i])		
			V_TRK_VMT[5][i]=nz(V_TRK_VMT[5][i])+nz(V_TRK_VMT[pd][i])
			V_TRK_VHT[5][i]=nz(V_TRK_VHT[5][i])+nz(V_TRK_VHT[pd][i])			
			V_CO[5][i]=nz(V_CO[5][i])+nz(V_CO[pd][i])
			V_NOX[5][i]=nz(V_NOX[5][i])+nz(V_NOX[pd][i])
			V_VOC[5][i]=nz(V_VOC[5][i])+nz(V_VOC[pd][i])
			V_CO2[5][i]=nz(V_CO2[5][i])+nz(V_CO2[pd][i])
			V_PM25[5][i]=nz(V_PM25[5][i])+nz(V_PM25[pd][i])
			V_PM10[5][i]=nz(V_PM10[5][i])+nz(V_PM10[pd][i])			
			
   
	// aggregate link attributes to total   //Town level
		t=1	//t = nz(V_Town_ID[i])   
			if t>0 then do
				V_T_VMT[pd][t]=nz(V_T_VMT[pd][t])+nz(V_VMT[pd][i])
				V_T_VHT[pd][t]=nz(V_T_VHT[pd][t])+nz(V_VHT[pd][i])
				V_T_Auto_VMT[pd][t]=nz(V_T_Auto_VMT[pd][t])+nz(V_Auto_VMT[pd][i])
				V_T_Auto_VHT[pd][t]=nz(V_T_Auto_VHT[pd][t])+nz(V_Auto_VHT[pd][i])				
				V_T_TRK_VMT[pd][t]=nz(V_T_TRK_VMT[pd][t])+nz(V_TRK_VMT[pd][i])
				V_T_TRK_VHT[pd][t]=nz(V_T_TRK_VHT[pd][t])+nz(V_TRK_VHT[pd][i])							
				V_T_CO[pd][t]=nz(V_T_CO[pd][t])+nz(V_CO[pd][i])
				V_T_NOX[pd][t]=nz(V_T_NOX[pd][t])+nz(V_NOX[pd][i])
				V_T_VOC[pd][t]=nz(V_T_VOC[pd][t])+nz(V_VOC[pd][i])
				V_T_CO2[pd][t]=nz(V_T_CO2[pd][t])+nz(V_CO2[pd][i])
				V_T_PM25[pd][t]=nz(V_T_PM25[pd][t])+nz(V_PM25[pd][i])
				V_T_PM10[pd][t]=nz(V_T_PM10[pd][t])+nz(V_PM10[pd][i])				
							
				T_PD_LinkCount[pd][t] =T_PD_LinkCount[pd][t] +1 

	// daily Town level
				V_T_VMT[5][t]=nz(V_T_VMT[5][t])+nz(V_VMT[pd][i])
				V_T_VHT[5][t]=nz(V_T_VHT[5][t])+nz(V_VHT[pd][i])
				V_T_Auto_VMT[5][t]=nz(V_T_Auto_VMT[5][t])+nz(V_Auto_VMT[pd][i])
				V_T_Auto_VHT[5][t]=nz(V_T_Auto_VHT[5][t])+nz(V_Auto_VHT[pd][i])						
				V_T_TRK_VMT[5][t]=nz(V_T_TRK_VMT[5][t])+nz(V_TRK_VMT[pd][i])
				V_T_TRK_VHT[5][t]=nz(V_T_TRK_VHT[5][t])+nz(V_TRK_VHT[pd][i])							
				V_T_CO[5][t]=nz(V_T_CO[5][t])+nz(V_CO[pd][i])
				V_T_NOX[5][t]=nz(V_T_NOX[5][t])+nz(V_NOX[pd][i])
				V_T_VOC[5][t]=nz(V_T_VOC[5][t])+nz(V_VOC[pd][i])
				V_T_CO2[5][t]=nz(V_T_CO2[5][t])+nz(V_CO2[pd][i])
				V_T_PM25[5][t]=nz(V_T_PM25[5][t])+nz(V_PM25[pd][i])
				V_T_PM10[5][t]=nz(V_T_PM10[5][t])+nz(V_PM10[pd][i])					
		
			T_PD_LinkCount[5][t] =T_PD_LinkCount[5][t] +1 
			
				end
			end  
	
		end   //for pd=1 to count_period -1 do

//Write the results into Town level bin table
	
	SW_Hwy_AQ_vw = RunMacro("TCB OpenTable",,, {SW_Hwy_AQ_Tab})	
	   ok = (SW_Hwy_AQ_vw <> null )
	    if !ok then goto quit
    	SetView(SW_Hwy_AQ_vw)		
		{V_AQ_ID}=GetDataVectors(SW_Hwy_AQ_vw+"|", {"Town_ID"},{{"Sort Order", {{"Town_ID", "Ascending"}  }}})
	
			for pd = 1 to count_period do
				SetDataVectors(SW_Hwy_AQ_vw +"|", {
				{prd[pd] +"_VMT",A2V(V_T_VMT[pd])},{prd[pd] + "_VHT",A2V(V_T_VHT[pd])}, {prd[pd]+"_Auto_VMT",A2V(V_T_Auto_VMT[pd])},{prd[pd] +"_Auto_VHT",A2V(V_T_Auto_VHT[pd])},
				{prd[pd] +"_Truck_VMT",A2V(V_T_TRK_VMT[pd])},{prd[pd] +"_Truck_VHT",A2V(V_T_TRK_VHT[pd])},
				{prd[pd] + "_VOC",A2V(V_T_VOC[pd])},{prd[pd] + "_NOX",A2V(V_T_NOX[pd])}, {prd[pd] + "_CO",A2V(V_T_CO[pd])},
				{prd[pd] + "_CO2",A2V(V_T_CO2[pd])}, {prd[pd] + "_PM25",A2V(V_T_PM25[pd])},
				{prd[pd] + "_PM10",A2V(V_T_PM10[pd])}},{{"Sort Order", {{"Town_ID", "Ascending"} }}})
			end
		
//Caculate and output the results at different geographic areas
 	
// Inputs
//showmessage("hello3")
   
		
   Report_file	= ProjectPath2 + "Reports\\File.txt"		
		
	date = GetDateAndTime()
		
	sp=SplitPath(Report_file)
	
	Highway_Air_Quality_Report = ProjectPath + "Reports\\"+"Statewide_Highway_Interzonal_Air_Quality.txt"
	rpt = OpenFile(Highway_Air_Quality_Report,"w")

	prd = {"AM", "MD", "PM", "NT", "Dly"}	
	
	count_period = prd.length 
 	
	
//AQ_area = {"BRPC","CCC","CMRPC","FRCOG","MAPC","MRPC","MVC","MVPC","NMCOG","NPEDC","OCPC","PVPC","SRPEDD","Suffolk MA", "Middlesex MA","Norfolk MA","Essex MA","Plymouth MA","Worcester MA","Bristol MA","Barnstable MA","Dukes MA","Nantucket MA","Hampden MA","Hampshire MA","Franklin MA","Berkshire MA", "BOSTON,MA", "CAMBRIDGE,MA", "CHELSEA,MA", "EVERETT,MA", "MALDEN,MA", //"MEDFORD,MA","REVERE,MA", "SOMERVILLE,MA","LYNNFIELD,MA", "PEABODY,MA","LYNN,MA","REVERE,MA","WAKEFIELD,MA","STONEHAM,MA","MELROSE,MA","SAUGUS,MA","WINTHROP,MA"} 


//AQ_area = {"BRPC","CCC","CMRPC","FRCOG","MAPC","MRPC","MVC","MVPC","NMCOG","NPEDC","OCPC","PVPC","SRPEDD"} 

	AQ_area = {"MAPC"}

 Len_AQ=AQ_area.length
 	
 	outline=null pad=13
 	
 	Dim AQ_V_VMT[count_period,AQ_area.length], AQ_V_VHT[count_period,AQ_area.length], AQ_V_AutoVMT[count_period,AQ_area.length], AQ_V_AutoVHT[count_period,AQ_area.length], 
	AQ_V_TRKVMT[count_period,AQ_area.length], AQ_V_TRKVHT[count_period,AQ_area.length], 
	AQ_V_VOC [count_period,AQ_area.length], AQ_V_NOx[count_period,AQ_area.length], 
	AQ_V_CO[count_period,AQ_area.length],AQ_V_CO2[count_period,AQ_area.length],AQ_V_PM25[count_period,AQ_area.length],AQ_V_PM10[count_period,AQ_area.length]
	
	Writeline(rpt,"Statewide_Model_Highway_Interzonal_Air_Quality_Report for GLX_AQ AQ Analysis: "+date)
	//if BaseBuild=1 then BaseBuild=No-Build
	//if BaseBuild=2 then BaseBuild=Build
	Writeline(rpt,I2s(Year))
	//Writeline(rpt,BaseBuild)
	
 	for pd=1 to count_period do

 		Writeline(rpt,"")
		Writeline(rpt,"") Writeline(rpt,"")
		Writeline(rpt,"************************************************************************************************************************************************************************************")
		Writeline(rpt,"Summary of Highway Air Quality in "+prd[pd])
		Writeline(rpt,"************************************************************************************************************************************************************************************")
		Writeline(rpt,"")
		Writeline(rpt,"                VMT(mi)       VHT(hr)    AutoVMT(mi)    AutoVHT(hr)   TRKVMT(mi)  TRKVHT(hr)      VOC-s(kg)     NOX-w(kg)      CO-s(kg)     CO2-w(kg)    PM25-w(kg)    PM10-s(kg)")	
		Writeline(rpt,"----------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- -------------")	
 
 		for aq=1 to AQ_area.length do
		
		
  			SetView(SW_Hwy_AQ_vw)
 			
							
		//	if aq<14 then do  // RPA
				
				query = "Select* where RPA='"+AQ_area[aq]+"'"
				AreaSummary = SelectByQuery("AreaSummary_"+AQ_area[aq], "Several", query,)
				{V_VMT,V_VHT,V_AutoVMT,V_AutoVHT,V_TRKVMT,V_TRKVHT,V_VOC,V_NOx, V_CO, V_CO2, V_PM25, V_PM10} 
				= GetDataVectors(SW_Hwy_AQ_vw + "|AreaSummary_"+AQ_area[aq],{prd[pd] +"_VMT",prd[pd] + "_VHT",
				prd[pd]+"_Auto_VMT",prd[pd] +"_Auto_VHT",prd[pd] +"_Truck_VMT",prd[pd] +"_Truck_VHT",
				prd[pd] + "_VOC",prd[pd] + "_NOX",prd[pd] + "_CO", prd[pd] + "_CO2", prd[pd] + "_PM25", prd[pd] + "_PM10"}, )
				

				AQ_V_VMT[pd][aq]  = VectorStatistic(V_VMT, "Sum", ) 
				AQ_V_VHT[pd][aq]  = VectorStatistic(V_VHT, "Sum", ) 
				AQ_V_AutoVMT[pd][aq]  = VectorStatistic(V_AutoVMT, "Sum", ) 
				AQ_V_AutoVHT[pd][aq]  = VectorStatistic(V_AutoVHT, "Sum", ) 
	
				AQ_V_TRKVMT[pd][aq]  = VectorStatistic(V_TRKVMT, "Sum", ) 
				AQ_V_TRKVHT[pd][aq]  = VectorStatistic(V_TRKVHT, "Sum", ) 
				AQ_V_VOC[pd][aq]  = VectorStatistic(V_VOC, "Sum", ) 
				AQ_V_NOx[pd][aq]  = VectorStatistic(V_NOx, "Sum", ) 
				AQ_V_CO[pd][aq]   = VectorStatistic(V_CO, "Sum", ) 
				AQ_V_CO2[pd][aq]  = VectorStatistic(V_CO2, "Sum", ) 
				AQ_V_PM25[pd][aq]   = VectorStatistic(V_PM25, "Sum", ) 
				AQ_V_PM10[pd][aq]  = VectorStatistic(V_PM10, "Sum", ) 		
				
	
		//	end
/*
			else if aq>13 and aq<28 then do  // County
				
				query = "Select* where County='"+AQ_area[aq]+"'"
				{V_VMT,V_VHT,V_AutoVMT,V_AutoVHT,V_TRKVMT,V_TRKVHT,V_VOC,V_NOx, V_CO, V_CO2,V_PM25, V_PM10} 
				= GetDataVectors(SW_Hwy_AQ_vw + "|AreaSummary_"+AQ_area[aq],{prd[pd] +"_VMT",prd[pd] + "_VHT",
				prd[pd]+"_Auto_VMT",prd[pd] +"_Auto_VHT",prd[pd] +"_Truck_VMT",prd[pd] +"_Truck_VHT",
				prd[pd] + "_VOC",prd[pd] + "_NOX",prd[pd] + "_CO", prd[pd] + "_CO2", prd[pd] + "_PM25", prd[pd] + "_PM10"}, )

					AQ_V_VMT[pd][aq]  = VectorStatistic(V_VMT, "Sum", ) 
					AQ_V_VHT[pd][aq]  = VectorStatistic(V_VHT, "Sum", ) 
        			AQ_V_AutoVMT[pd][aq]  = VectorStatistic(V_AutoVMT, "Sum", ) 
        			AQ_V_AutoVHT[pd][aq]  = VectorStatistic(V_AutoVHT, "Sum", ) 
      
        			AQ_V_TRKVMT[pd][aq]  = VectorStatistic(V_TRKVMT, "Sum", ) 
        			AQ_V_TRKVHT[pd][aq]  = VectorStatistic(V_TRKVHT, "Sum", ) 
					AQ_V_VOC[pd][aq]  = VectorStatistic(V_VOC, "Sum", ) 
					AQ_V_NOx[pd][aq]  = VectorStatistic(V_NOx, "Sum", ) 
					AQ_V_CO[pd][aq]   = VectorStatistic(V_CO, "Sum", ) 
					AQ_V_CO2[pd][aq]  = VectorStatistic(V_CO2, "Sum", ) 
					AQ_V_PM25[pd][aq]   = VectorStatistic(V_PM25, "Sum", ) 
					AQ_V_PM10[pd][aq]  = VectorStatistic(V_PM10, "Sum", ) 				
					
		
				end	
								
			else do  //Selected Cities
					
					query = "Select* where Town='"+AQ_area[aq]+"'"
				{V_VMT,V_VHT,V_AutoVMT,V_AutoVHT,V_TRKVMT,V_TRKVHT,V_VOC,V_NOx, V_CO, V_CO2,V_PM25, V_PM10} 
				= GetDataVectors(SW_Hwy_AQ_vw + "|AreaSummary_"+AQ_area[aq],{prd[pd] +"_VMT",prd[pd] + "_VHT",
				prd[pd]+"_Auto_VMT",prd[pd] +"_Auto_VHT",prd[pd] +"_Truck_VMT",prd[pd] +"_Truck_VHT",
				prd[pd] + "_VOC",prd[pd] + "_NOX",prd[pd] + "_CO", prd[pd] + "_CO2", prd[pd] + "_PM25", prd[pd] + "_PM10"}, )

					AQ_V_VMT[pd][aq]  = VectorStatistic(V_VMT, "Sum", ) 
					AQ_V_VHT[pd][aq]  = VectorStatistic(V_VHT, "Sum", ) 
        			AQ_V_AutoVMT[pd][aq]  = VectorStatistic(V_AutoVMT, "Sum", ) 
        			AQ_V_AutoVHT[pd][aq]  = VectorStatistic(V_AutoVHT, "Sum", ) 
      
        			AQ_V_TRKVMT[pd][aq]  = VectorStatistic(V_TRKVMT, "Sum", ) 
        			AQ_V_TRKVHT[pd][aq]  = VectorStatistic(V_TRKVHT, "Sum", ) 
					AQ_V_VOC[pd][aq]  = VectorStatistic(V_VOC, "Sum", ) 
					AQ_V_NOx[pd][aq]  = VectorStatistic(V_NOx, "Sum", ) 
					AQ_V_CO[pd][aq]   = VectorStatistic(V_CO, "Sum", ) 
					AQ_V_CO2[pd][aq]  = VectorStatistic(V_CO2, "Sum", ) 
					AQ_V_PM25[pd][aq]   = VectorStatistic(V_PM25, "Sum", ) 
					AQ_V_PM10[pd][aq]  = VectorStatistic(V_PM10, "Sum", ) 									
					
				end
*/				
  			// pad +1, add one extra space for the blank between numbers
			S1= Format(r2i(AQ_V_VMT[pd][aq] *1),"*,")				L=len(S1) for K=L+1 to pad+1 do S1 = ' '+S1 end
			S2= Format(r2i(AQ_V_VHT[pd][aq] *1),"*,")				L=len(S2) for K=L+1 to pad+1 do S2 = ' '+S2 end
			S3= Format(r2i(AQ_V_AutoVMT[pd][aq] *1),"*,")			L=len(S3) for K=L+1 to pad+1 do S3 = ' '+S3 end
			S4= Format(r2i(AQ_V_AutoVHT[pd][aq] *1),"*,")			L=len(S4) for K=L+1 to pad+1 do S4 = ' '+S4 end
		
			S7= Format(r2i(AQ_V_TRKVMT[pd][aq] *1),"*,")			L=len(S7) for K=L+1 to pad+1 do S7 = ' '+S7 end
			S8= Format(r2i(AQ_V_TRKVHT[pd][aq] *1),"*,")			L=len(S8) for K=L+1 to pad+1 do S8 = ' '+S8 end
			S9= Format(r2i(AQ_V_VOC[pd][aq] ),"*,")			L=len(S9) for K=L+1 to pad+1 do S9 = ' '+S9 end	
			S10= Format(r2i(AQ_V_NOx[pd][aq]),"*,")			L=len(S10) for K=L+1 to pad+1 do S10 = ' '+S10 end	
			S11= Format(r2i(AQ_V_CO[pd][aq] ),"*,")			L=len(S11) for K=L+1 to pad+1 do S11 = ' '+S11 end 	
			S12= Format(r2i(AQ_V_CO2[pd][aq] ),"*,")			L=len(S12) for K=L+1 to pad+1 do S12 = ' '+S12 end
			S13= Format(r2i(AQ_V_PM25[pd][aq] ),"*,")			L=len(S13) for K=L+1 to pad+1 do S13 = ' '+S13 end
			S14= Format(r2i(AQ_V_PM10[pd][aq] ),"*,")			L=len(S14) for K=L+1 to pad+1 do S14 = ' '+S14 end			
	

			Sname=AQ_area[aq]  L=len(Sname) for K=L+1 to pad do Sname = Sname+' ' end
			outline= S1 + S2 + S3 + S4 + S7 + S8 + S9 + S10 + S11+ S12 +  S13+ S14 
			WriteLine(rpt, Sname+outline) 			
 		end  //for aq=1 to AQ_area.length do
		
 		Writeline(rpt,"----------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- ------------- -------------")	
		
	end   //  for pd=1 to count_period do
CloseFile(rpt)
	
	quit:
	ShowMessage("Statewide Highway interzonal AQ Finished.")
    
    ok = 1
	return(ok)

	RunMacro("G30 File Close All")
	Return( RunMacro("TCB Closing", , True ) )

endmacro
