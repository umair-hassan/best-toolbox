classdef app < handle
    
    
    properties
        var
        grid % bottom most 3 panels
        panel
        pulse
        a1
        a2
        bst
        info
        data
        vp
        mrtms_panel_stimulation_paradigm
        mep_panel_update_btn
        mep_panel_run_btn
        mep_panel_stop_btn
        inputs
        axesH
    end
    
    methods
        function obj = app()
            obj.bst=best_toolbox_gui(obj);
            f = figure('Tag','umi1','ToolBar','none','Name','BEST Toolbox','NumberTitle','off');
            
            obj.info.session_no=0;
            obj.info.measurement_no=0;
            obj.info.event.current_session={};
            obj.info.event.current_measure={};
            
            
            set(gcf, 'Position', get(0, 'Screensize'));
            obj.grid = uix.GridFlex( 'Parent', f, 'Spacing', 5 );
            p_measurement_designer = uix.Panel( 'Parent', obj.grid, 'Padding', 5,  'Units','normalized','BorderType','none');
            p = uix.Panel( 'Parent', p_measurement_designer, 'Title', 'Measurement Designer', 'Padding', 5,'FontSize',14 ,'Units','normalized','FontWeight','bold' );
            p.TitlePosition='centertop';
            c = uix.VBox( 'Parent', p, 'Spacing', 5, 'Padding', 5  );
            
            % experiment title: first horizontal row on first panel
            b = uix.HBox( 'Parent', c, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', b,'String','Experiment Title:','FontSize',11,'HorizontalAlignment','left','Units','normalized' );
            uicontrol( 'Style','edit','Parent', b ,'FontSize',11)
            uicontrol( 'Parent', b ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir )
            set( b, 'Widths', [120 -0.7 -0.09]);
            
            % subject code: second horizontal row on first panel
            bb = uix.HBox( 'Parent', c, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', bb,'String','Subject Code:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', bb ,'FontSize',11);
            uicontrol( 'Parent', bb ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir )
            set( bb, 'Widths', [120 -0.7 -0.09]);
            
            % session title edit box: third horizontal row on first panel
            bbb = uix.HBox( 'Parent', c, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', bbb,'String','Session Title:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            obj.var.session_title=uicontrol( 'Style','edit','Parent', bbb ,'FontSize',11);
            uicontrol( 'Parent', bbb ,'Style','PushButton','String','+','FontWeight','Bold','Callback',@obj.session_add)
            set( bbb, 'Widths', [120 -0.7 -0.09]);
            
            % drop-down select measure: fourth horizontal row on first panel
            fourth_row = uix.HBox( 'Parent', c, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', fourth_row,'String','Select Measure:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            obj.var.dd.measure={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','MEP Dose Response Curve_sp','MEP Dose Response Curve_pp','EEG triggered TMS','fMRI triggered TMS','TEP Measurement'};
            obj.var.measure_title=uicontrol( 'Style','popupmenu','Parent', fourth_row ,'FontSize',11,'String',obj.var.dd.measure);
            uicontrol( 'Parent', fourth_row ,'Style','PushButton','String','+','FontWeight','Bold','Callback',@obj.measure_add)
            set( fourth_row, 'Widths', [120 -0.7 -0.09]);
            
            
            % ---------------------------------------------fifth horizontal row on first panel
            fifth_row = uix.HBox( 'Parent', c, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', fifth_row,'String','','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            uicontrol( 'Style','text','Parent', fifth_row ,'FontSize',11,'String','');
            uicontrol( 'Parent', fifth_row ,'Style','text','String','','FontWeight','Bold')
            set( fifth_row, 'Widths', [120 -0.7 -0.05]);
            
            % text session: sixth horizontal row on first panel
            uicontrol( 'Style','text','Parent', c,'String','Sessions','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            % sessions listbox: seventh horizontal row on first panel
            obj.var.session_lb1={};
            
            m_sessions=uicontextmenu(f);
            
            
            mus1 = uimenu(m_sessions,'label','Copy');
            mus2 = uimenu(m_sessions,'label','Paste Above');
            mus3 = uimenu(m_sessions,'label','Paste Below');
            mus4 = uimenu(m_sessions,'label','Delete');
        
            
            obj.var.session_lbh=uicontrol( 'Style','listbox','Parent', c ,'FontSize',11,'String',obj.var.session_lb1,'uicontextmenu',m_sessions,'Callback',@obj.session_listbox_callback);
            
            %----------------------------------------------8th horizontal row on first panel
            uicontrol( 'Style','text','Parent', c,'String','Protocol','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            %----------------------------------------------9th horizontal row on first panel
            %             measure_lb2={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','Dose-Response Curve (MEP-sp)','Dose-Response Curve (MEP-pp)','EEG triggered TMS','MR triggered TMS','TEP Measurement'};
            measure_lb2={};
            m=uicontextmenu(f);
            
            
            mu1 = uimenu(m,'label','Copy');
            mu2 = uimenu(m,'label','Paste Above');
            mu3 = uimenu(m,'label','Paste Below');
            mu4 = uimenu(m,'label','Delete');
            mu5 = uimenu(m,'label','Help');

            
            
            
            obj.var.measure_lbh=uicontrol( 'Style','listbox','Parent', c ,'FontSize',11,'String',measure_lb2,'uicontextmenu',m,'ButtonDownFcn',@bdf_t,'Callback',@obj.measurement_listbox_callback);
            m=uicontextmenu(f);
            
            
            
            
            
            
            % ax=axes(c)
            % %plot(ax,1:10,2:2:20)
            % image(imread('del.png'))
            
            %  pb=uicontrol( 'Parent', c ,'Style','PushButton','Background', 'w' )
            % pb.CData=imread('del.png')
            set( c, 'Heights', [-0.05 -0.05 -0.05 -0.05 0 -0.04 -0.11 -0.04 -0.63]);
            
%             
             obj.empty_panel;
             obj.no_measure_selected;
%              obj.mep_panel;
            % obj.thresholding_panel;


             
             
            
              
            obj.third_panel;
            
            obj.var.i=0;
            obj.var.measure_no=0;
        end
        
        function session_add(obj,src,eventdata)
            
            obj.info.session_no=obj.info.session_no+1;
            
            session_name=obj.var.session_title.String;
            obj.info.session_matrix(obj.info.session_no)={obj.var.session_title.String};
            obj.var.session_lb1(obj.info.session_no)={obj.var.session_title.String};
            session_EXIST=1;
            session_EXIST_list2=1;
            if  obj.info.session_no>1
                for N= 1: obj.info.session_no-1
                    
                    session_exist_no=(strcmp(obj.info.session_matrix(N),{obj.var.session_title.String}));
                    if session_exist_no==1
                        
                        session_EXIST=session_EXIST+1;
                        string_AA='_';
                        session_name=strcat(obj.var.session_title.String,string_AA,(num2str(session_EXIST)));
                    end
                end
                
                if(session_EXIST<3)
                    for N= 1: obj.info.session_no-1
                        
                        session_exist_no_list2=(strcmp( obj.var.session_lb1(N),{obj.var.session_title.String}));
                        if session_exist_no_list2==1
                            
                            session_EXIST_list2=session_EXIST_list2+1;
                            string_AA='_';
                            session_name=strcat(obj.var.session_title.String,string_AA,(num2str( session_EXIST_list2)));
                        end
                    end
                end
            end
            
            obj.var.session_lb1(1,obj.info.session_no)={session_name};
            obj.var.session_lbh.String=obj.var.session_lb1;
            
            obj.var.session_title.String='';
            obj.var.session_lbh.Max=2;
            obj.var.session_lbh.Value=[];
            session_name(session_name == ' ') = '_';
            obj.data.(session_name).info.measurement_str={};
            obj.data.(session_name).info.measurement_no=0;
            obj.data.(session_name).info.measurement_str_to_listbox={};
            
            
            session_name=[];
            
            
            
        end
        
        function measure_add(obj,src,eventdata)
obj.info.event.current_session=obj.var.session_lbh.String(obj.var.session_lbh.Value)
            obj.info.event.current_session=obj.info.event.current_session{1}
                        obj.info.event.current_session(obj.info.event.current_session == ' ') = '_';

            obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no+1;
            obj.data.(obj.info.event.current_session).info.measurement_str(1,obj.data.(obj.info.event.current_session).info.measurement_no)=obj.var.dd.measure(obj.var.measure_title.Value);
            
            
            measure_name= obj.var.dd.measure(obj.var.measure_title.Value);
            
            
            measure_EXIST=1;
            
            if  obj.data.(obj.info.event.current_session).info.measurement_no>1
                for N= 1: obj.data.(obj.info.event.current_session).info.measurement_no-1
                    
                    measure_exist_no=(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str(N), obj.var.dd.measure(obj.var.measure_title.Value)));
                    if measure_exist_no==1
                        
                        measure_EXIST=measure_EXIST+1;
                        string_AA='_';
                        measure_name=strcat(obj.var.dd.measure(obj.var.measure_title.Value),string_AA,(num2str(measure_EXIST)));
                    end
                end
                
                
            end
            
            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1,obj.data.(obj.info.event.current_session).info.measurement_no)=measure_name;
            
            
            
            
            
            
            obj.var.measure_lbh.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
            
            
            measure_name=measure_name{1}
            measure_name(measure_name == ' ') = '_';
            obj.data.(obj.info.event.current_session).(measure_name).mep.target_muscle={}
            
            measure_name=[];
            obj.session_listbox_callback
            obj.measurement_listbox_callback
            
            
            
            
        end
        
        function no_measure_selected(obj)
            
           % obj.pulse.input = uix.Panel( 'Parent', obj.grid, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            obj.panel.input=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','Inputs Panel','FontWeight','Bold' );
            obj.panel.input.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.input, 'Spacing', 5, 'Padding', 5  );
            uiextras.HBox( 'Parent', obj.panel.vb)
            obj.panel.t1= uicontrol( 'Parent', obj.panel.vb,'Style','text','String','No Protocol is selected','FontSize',11,'HorizontalAlignment','center','Units','normalized' );
            uiextras.HBox( 'Parent', obj.panel.vb)
            obj.panel.st=set(obj.panel.vb,'Heights',[-2 -0.5 -2])
            
            %set(obj.vp,'Heights',[-1 0])
            
        end
        
        function empty_panel(obj)
                        obj.pulse.input = uix.Panel( 'Parent', obj.grid, 'Padding', 5 ,'Units','normalized','BorderType','none' );
                       % obj.vp=uix.VBox( 'Parent', obj.pulse.input, 'Spacing', 5, 'Padding', 5  );
        end
        function mep_panel(obj)
            
            
            obj.panel.mep=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','MEP Measurement' ,'FontWeight','Bold');
            obj.panel.mep.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.mep, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Stimulation Paradigm:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
            obj.inputs.mep.stimulation_paradigm=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'Single Pulse', 'Paired Pulse','Burst'});
            mep_panel_row1.Widths=[150 -2];
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@obj.cb_mep_target_muscle);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            %% stim intensity units to come here sooner %%
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            
            
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15');
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 9
            mep_panel_row9 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row9,'String','MEP offset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row9 ,'FontSize',11,'String','50');
            set( mep_panel_row9, 'Widths', [150 -2]);
            
            %row 10
            mep_panel_row10 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Prestim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.prestim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50');
            set( mep_panel_row10, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Poststim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.poststim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150');
            set( mep_panel_row11, 'Widths', [150 -2]);
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1);
            obj.inputs.mep.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure');
            
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
         
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000');
            set( mep_panel_15, 'Widths', [150 -2]);

            
             % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Y Axis Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','-8000');
            set( mep_panel_16, 'Widths', [150 -2]);
            
               % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12');
            
            set( mep_panel_14, 'Widths', [150 -2]);
            
            

            
            
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );

            obj.mep_panel_update_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@obj.rcb_btn)
            obj.mep_panel_run_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@obj.rcb)
            obj.mep_panel_stop_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@obj.stop,'Enable','on')
            set( mep_panel_17, 'Widths', [-2 -4 -2]);

            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.5])
            
            
          
        end
        
        function hotspot_panel(obj)
                        
            obj.panel.hotspot=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','Motor Hotspot Search','FontWeight','Bold' );
            obj.panel.hotspot.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.hotspot, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
%             mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
%             uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Stimulation Paradigm:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
%             uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'Single Pulse', 'Paired Pulse','Burst'});
%             mep_panel_row1.Widths=[150 -2];
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.hotspot_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensity (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            %% stim intensity units to come here sooner %%
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            
            
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15');
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 9
            mep_panel_row9 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row9,'String','MEP offset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row9 ,'FontSize',11,'String','50');
            set( mep_panel_row9, 'Widths', [150 -2]);
            
            %row 10
            mep_panel_row10 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Prestim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.prestim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50');
            set( mep_panel_row10, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Poststim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.poststim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150');
            set( mep_panel_row11, 'Widths', [150 -2]);

            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000');
            set( mep_panel_15, 'Widths', [150 -2]);

            
             % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Y Axis Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','-8000');
            set( mep_panel_16, 'Widths', [150 -2]);
            
               % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mep.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12');
            
            set( mep_panel_14, 'Widths', [150 -2]);
            
            

            
            
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );

            obj.mep_panel_update_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@obj.rcb_btn)
            obj.mep_panel_run_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@obj.rcb_hotspot)
            obj.mep_panel_stop_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@obj.stop)
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.5 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -1 -0.5])

        end
        
        function thresholding_panel(obj)
              
            obj.panel.thresholding=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','Motor Threshold Hunting','FontWeight','Bold' );
            obj.panel.thresholding.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.thresholding, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Thresholding Method:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
            obj.inputs.mt.thresholding_method=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'PEST Pentland', 'PEST Taylor'});
            mep_panel_row1.Widths=[150 -2];
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 2
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.motor_threshold=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);

            
            %% stim intensity units to come here sooner %%
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
                        % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','No. of Trials to Avg:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.trialstoavg=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);

            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            
            
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15');
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 9
            mep_panel_row9 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row9,'String','MEP offset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row9 ,'FontSize',11,'String','50');
            set( mep_panel_row9, 'Widths', [150 -2]);
            
            %row 10
            mep_panel_row10 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Prestim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.prestim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50');
            set( mep_panel_row10, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Poststim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.poststim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150');
            set( mep_panel_row11, 'Widths', [150 -2]);
            
           
            
            
                      % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000');
            set( mep_panel_15, 'Widths', [150 -2]);

            
             % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Y Axis Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','-8000');
            set( mep_panel_16, 'Widths', [150 -2]);
            
               % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.mt.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12');
            
            set( mep_panel_14, 'Widths', [150 -2]);
            
            

            
            
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );

            obj.mep_panel_update_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@obj.cb_update_mt,'Enable','on')
            obj.mep_panel_run_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@obj.rcb_thresholding)
            obj.mep_panel_stop_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@obj.stop,'Enable','on')
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.5 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.1 -0.5])
            
        end
        
        function mrtms_panel(obj)
             obj.panel.mrtms=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','fMRI triggered TMS' ,'FontWeight','Bold');
            obj.panel.mrtms.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.mrtms, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Stimulation Paradigm:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
            obj.mrtms_panel_stimulation_paradigm=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'Single Pulse', 'Paired Pulse','Burst'},'Callback',@obj.callback_mrtms_paradigm);
            mep_panel_row1.Widths=[150 -2];
            
            % row 3
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Time of Acquisition - TA (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 4
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Trigger Delay (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 5
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Total Volumes:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 6
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Volume Triggering Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 7
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            


            % row 8
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 9
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            

            
            % row 10
            mep_panel_row12 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_inten=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO');
            uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 11
            mep_panel_13 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure');
            
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 12
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 13
            uicontrol( 'Parent', obj.panel.vb ,'Style','PushButton','String','RUN','FontWeight','Bold','Callback',@obj.rcb)
            
            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4  -1 -0.5])
            obj.info.(obj.info.event.current_session).(obj.info.event.current_measure).counter=0;
        end
        
        function mrtms_pp_panel(obj)
               obj.panel.mrtms_pp=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','fMRI triggered TMS','FontWeight','Bold' );
            obj.panel.mrtms_pp.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.mrtms_pp, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Stimulation Paradigm:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
            obj.mrtms_panel_stimulation_paradigm=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'Single Pulse', 'Paired Pulse','Burst'},'Value',2,'Callback',@obj.callback_mrtms_paradigm);
            mep_panel_row1.Widths=[150 -2];
            
            % row 3
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Time of Acquisition - TA (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 4
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Trigger Delay (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 5
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Total Volumes:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 6
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Volume Triggering Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 7
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Condition Stimulus Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
                        % row 7
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Test Stimulus Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
                         % row 7 2
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Inter Stimulus Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            


            % row 8
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 9
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            

            
            % row 10
            mep_panel_row12 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_pp_inten=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO');
            uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 11
            mep_panel_13 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure');
            
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 12
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 13
            uicontrol( 'Parent', obj.panel.vb ,'Style','PushButton','String','RUN','FontWeight','Bold','Callback',@obj.rcb)
            
            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4  -1 -0.5])
            
        end
        
        function mrtms_burst_panel(obj)
            obj.panel.mrtms_burst=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','fMRI triggered TMS' ,'FontWeight','Bold');
            obj.panel.mrtms_burst.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.mrtms_burst, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row1 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Stimulation Paradigm:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized')
            obj.mrtms_panel_stimulation_paradigm=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'Single Pulse', 'Paired Pulse','Burst'},'Value',3,'Callback',@obj.callback_mrtms_paradigm);
            mep_panel_row1.Widths=[150 -2];
            
            % row 3
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Time of Acquisition - TA (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 4
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Trigger Delay (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 5
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Total Volumes:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
             % row 6
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Volume Triggering Conditions:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 7
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
                        % row 7
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Burst Pulses:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
                         % row 7 2
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Inter Pulse Interval (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
             % row 7 2
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Current Direction:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            


            % row 8
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 9
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            

            
            % row 10
            mep_panel_row12 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.panel.mrtms_burst_inten=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO');
            uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 11
            mep_panel_13 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure');
            
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 12
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 13
            uicontrol( 'Parent', obj.panel.vb ,'Style','PushButton','String','RUN','FontWeight','Bold','Callback',@obj.rcb)
            
            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4  -1 -0.5])
            
        end
        
        function ioc_panel(obj)
            
            
            obj.panel.mep=uix.Panel( 'Parent', obj.pulse.input,'FontSize',14 ,'Units','normalized','Title','Dose-Response Curve (MEP-sp)' ,'FontWeight','Bold');
            obj.panel.mep.TitlePosition='centertop';
            obj.panel.vb = uix.VBox( 'Parent', obj.panel.mep, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.panel.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            %% stim intensity units to come here sooner %%
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.panel.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            
            
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15');
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 9
            mep_panel_row9 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row9,'String','MEP offset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row9 ,'FontSize',11,'String','50');
            set( mep_panel_row9, 'Widths', [150 -2]);
            
            %row 10
            mep_panel_row10 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Prestim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.prestim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50');
            set( mep_panel_row10, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Poststim. Scope (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.poststim_scope=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150');
            set( mep_panel_row11, 'Widths', [150 -2]);
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1);
            obj.inputs.ioc.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure');
            
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
         
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','MEP Y-axis Max (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','+7000');
            set( mep_panel_15, 'Widths', [150 -2]);

            
             % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','MEP Y-axis Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','-7000');
            set( mep_panel_16, 'Widths', [150 -2]);
            
               % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.inputs.ioc.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12');
            
            set( mep_panel_14, 'Widths', [150 -2]);
            
            

            
            
            
            uiextras.HBox( 'Parent', obj.panel.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.panel.vb, 'Spacing', 5, 'Padding', 5  );

            obj.mep_panel_update_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@obj.cb_update_ioc)
            obj.mep_panel_run_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@obj.cb_run_ioc)
            obj.mep_panel_stop_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@obj.stop,'Enable','on')
            set( mep_panel_17, 'Widths', [-2 -4 -2]);

            
            
            obj.panel.st=set(obj.panel.vb,'Heights',[-0.2 -0.4 -0.4 -0.4 -0.4 -0.1 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.5 -0.5 -0.4 0 -0.5])
            
            
          
        end
        
        function third_panel(obj)
            obj.panel.output= uix.Panel( 'Parent', obj.grid, 'Padding', 5 ,'Units','normalized','BorderType','none' );
           
             uix.Panel( 'Parent', obj.panel.output, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );

            

            
  
            
            set( obj.grid, 'Widths', [-1.15 -1.35 -2] );
            
        end
        
        function mep_results(obj)
             obj.panel.mep_results= uix.Panel( 'Parent', obj.panel.output, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );

            obj.a1=axes( 'Parent', obj.panel.mep_results,'Units','normalized','Tag','mep');

        end
        
        function thresholding_results(obj)
            obj.panel.thresholding_results= uix.Panel( 'Parent', obj.panel.output, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.panel.thresholding_HBOX=uix.HBoxFlex( 'Parent', obj.panel.thresholding_results, 'Padding', 5 ,'Units','normalized' );
            obj.panel.mtp1= uix.Panel( 'Parent', obj.panel.thresholding_HBOX, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.panel.mtp2= uix.Panel( 'Parent', obj.panel.thresholding_HBOX, 'Padding', 5 ,'Units','normalized','Title', 'Live Intensity Trace','FontSize',12,'TitlePosition','centertop' );

            obj.axesH.mep_plot=axes( 'Parent', obj.panel.mtp1,'Units','normalized','Tag','mep');
            obj.axesH.thresholding_plot_thresholding=axes( 'Parent',obj.panel.mtp2,'Units','normalized','Tag','rmt');
            set(obj.panel.thresholding_HBOX,'Widths',[-1 -1])

        end
        
        function ioc_results(obj)
            obj.panel.ioc_results= uix.Panel( 'Parent', obj.panel.output, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            tab = uiextras.TabPanel( 'Parent', obj.panel.ioc_results, 'Padding', 5 );

            
            obj.panel.ioc_HBOX=uix.HBoxFlex( 'Parent', tab, 'Padding', 5 ,'Units','normalized' );
                        

            obj.panel.iocp1= uix.Panel( 'Parent', obj.panel.ioc_HBOX, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.panel.iocp2= uix.Panel( 'Parent', obj.panel.ioc_HBOX, 'Padding', 5 ,'Units','normalized','Title', 'MEP P2P Scatt Plot','FontSize',12,'TitlePosition','centertop' );

            obj.axesH.mep_plot=axes( 'Parent', obj.panel.iocp1,'Units','normalized','Tag','mep');
            obj.axesH.scat_plot_ioc=axes( 'Parent',obj.panel.iocp2,'Units','normalized','Tag','ioc');
            set(obj.panel.ioc_HBOX,'Widths',[-1 -1])
            
            obj.panel.iocp3= uix.Panel( 'Parent', tab, 'Padding', 5 ,'Units','normalized','Title', 'Fitted Dose-Response Curve','FontSize',12,'TitlePosition','centertop' );
            obj.axesH.fit_plot_ioc=axes( 'Parent',obj.panel.iocp3,'Units','normalized','Tag','ioc_fit');
            tab.TabNames={'Live Results','Fitted IOC'}
            tab.SelectedChild=1;
            tab.TabSize=200;
            tab.FontSize=12;
            

        end
        function beest=rcb(obj,src,eventdata,bt)
%             obj.mep_panel_run_btn.Enable='off';
%             obj.mep_panel_update_btn.Enable='on';
%             obj.mep_panel_stop_btn.Enable='on';            

            
            obj.bst.inputs.stimuli=[str2num(obj.inputs.mep.stimulation_intensities.String)];
            obj.bst.inputs.iti=[str2num(obj.inputs.mep.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.mep.trials_per_condition.String)];
            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=NaN;
            obj.bst.inputs.mep_amthreshold=NaN;     
            obj.bst.inputs.mt_method=NaN;           
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.mep.mep_onset.String))/1000];          
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.mep.mep_offset.String))/1000];          
            
            
            scope=str2num(obj.inputs.mep.poststim_scope.String)+str2num(obj.inputs.mep.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mep.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.FontSize=str2num(obj.inputs.mep.FontSize.String)
            obj.bst.inputs.ylim_min=str2num(obj.inputs.mep.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.mep.ylim_max.String)

            
            
            obj.mep_results;
            obj.bst.best_mep()

            
% % %             obj.bst.inputs.stimuli=[40 50 60];
% % %             obj.bst.inputs.iti=[2 3];
% % %             obj.bst.inputs.isi=NaN;
% % %             obj.bst.inputs.trials=12;
% % %             obj.bst.inputs.stimunits=NaN;
% % %             obj.bst.inputs.motor_threshold=NaN;
% % %             obj.bst.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
% % %             obj.bst.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
% % %             obj.bst.inputs.mep_onset=0.015;           %mep post trigger onset in seconds %set default
% % %             obj.bst.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
% % %             
% % %             obj.bst.inputs.sc_samples=1000;
% % %             obj.bst.inputs.sc_prepostsamples=-10;
% % %             obj.bst.inputs.sc_samplingrate=5000;
% % %             obj.bst.inputs.mt_trialstoavg=10;
% % %             obj.bst.inputs.stim_mode='MSO';
% % %             obj.mep_results;
% % %             obj.bst.best_motorthreshold()
            % p=plot(1:10,1:10,'Parent',obj.a1)
            %  legend(p,'first','Location','northeastoutside')
            
            
        end
        
        function beest=rcb_hotspot(obj,src,eventdata,bt)
%             obj.mep_panel_run_btn.Enable='off';
%             obj.mep_panel_update_btn.Enable='on';
%             obj.mep_panel_stop_btn.Enable='on';            obj.bst.inputs.ylim_min=str2num(obj.inputs.ylim_min.String)

            
            obj.bst.inputs.stimuli=[str2num(obj.inputs.mep.stimulation_intensities.String)];
            obj.bst.inputs.iti=[str2num(obj.inputs.mep.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.mep.trials_per_condition.String)];
            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=NaN;
            obj.bst.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
            obj.bst.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.mep_onset.String))/1000];           %mep post trigger onset in seconds %set default
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.mep_offset.String))/1000];          %mep post trigger offset in seconds %set default
            
            
            scope=str2num(obj.inputs.mep.poststim_scope.String)+str2num(obj.inputs.mep.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mep.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.FontSize=str2num(obj.inputs.mep.FontSize.String)
            obj.bst.inputs.ylim_min=str2num(obj.inputs.mep.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.mep.ylim_max.String)

            
            
            obj.mep_results;
            obj.bst.best_mep()

            
% % %             obj.bst.inputs.stimuli=[40 50 60];
% % %             obj.bst.inputs.iti=[2 3];
% % %             obj.bst.inputs.isi=NaN;
% % %             obj.bst.inputs.trials=12;
% % %             obj.bst.inputs.stimunits=NaN;
% % %             obj.bst.inputs.motor_threshold=NaN;
% % %             obj.bst.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
% % %             obj.bst.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
% % %             obj.bst.inputs.mep_onset=0.015;           %mep post trigger onset in seconds %set default
% % %             obj.bst.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
% % %             
% % %             obj.bst.inputs.sc_samples=1000;
% % %             obj.bst.inputs.sc_prepostsamples=-10;
% % %             obj.bst.inputs.sc_samplingrate=5000;
% % %             obj.bst.inputs.mt_trialstoavg=10;
% % %             obj.bst.inputs.stim_mode='MSO';
% % %             obj.mep_results;
% % %             obj.bst.best_motorthreshold()
            % p=plot(1:10,1:10,'Parent',obj.a1)
            %  legend(p,'first','Location','northeastoutside')
            
            
        end
        
        function rcb_thresholding(obj,src,eventdata,bt)
%             obj.mep_panel_run_btn.Enable='off';
%             obj.mep_panel_update_btn.Enable='on';
%             obj.mep_panel_stop_btn.Enable='on';
 
            obj.bst.inputs.iti=[str2num(obj.inputs.mt.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.mt.trials_per_condition.String)];
            obj.inputs.mt_trialstoavg=[str2num(obj.inputs.mt.trialstoavg.String)];

            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=[str2num(obj.inputs.mt.motor_threshold.String)];
            obj.bst.inputs.mt_method=NaN;           
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.mt.mep_onset.String))/1000];          
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.mt.mep_offset.String))/1000];          
            
            
            scope=str2num(obj.inputs.mt.poststim_scope.String)+str2num(obj.inputs.mt.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mt.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.FontSize=str2num(obj.inputs.mt.FontSize.String)
            obj.bst.inputs.ylim_min=str2num(obj.inputs.mt.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.mt.ylim_max.String)

% % % % % % % %             obj.bst.inputs.stimuli=[40 50 60];
% % % % % % % %             obj.bst.inputs.iti=[2 3];
% % % % % % % %             obj.bst.inputs.isi=NaN;
% % % % % % % %             obj.bst.inputs.trials=20;
% % % % % % % %             obj.bst.inputs.stimunits=NaN;
% % % % % % % %             obj.bst.inputs.motor_threshold=0.05;
% % % % % % % %             obj.bst.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
% % % % % % % %             obj.bst.inputs.mt_method='PEST Taylor';           %motor thresholding (mt) method in volts %set default
% % % % % % % %             obj.bst.inputs.mep_onset=0.015;           %mep post trigger onset in seconds %set default
% % % % % % % %             obj.bst.inputs.mep_offset=0.050;          %mep post trigger offset in seconds %set default
% % % % % % % %             
% % % % % % % %             obj.bst.inputs.sc_samples=1000;
% % % % % % % %             obj.bst.inputs.sc_prepostsamples=-10;
% % % % % % % %             obj.bst.inputs.sc_samplingrate=5000;
% % % % % % % %             obj.bst.inputs.mt_trialstoavg=10;
% % % % % % % %             obj.bst.inputs.stim_mode='MSO';
            obj.thresholding_results;
            obj.bst.best_motorthreshold()
            % p=plot(1:10,1:10,'Parent',obj.a1)
            %  legend(p,'first','Location','northeastoutside')
            
            
        end
        
        function session_listbox_callback(obj,src,eventdata)
            
            obj.info.event.current_session=obj.var.session_lbh.String(obj.var.session_lbh.Value)
            obj.info.event.current_session=obj.info.event.current_session{1}
            obj.info.event.current_session(obj.info.event.current_session == ' ') = '_';
            obj.var.measure_lbh.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
            
            
        end
        
        
        function measurement_listbox_callback(obj,src,eventdata)
            obj.info.event.current_measure=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.var.measure_lbh.Value)
            obj.info.event.current_measure=obj.info.event.current_measure{1}

            
            
            switch obj.info.event.current_measure
                case 'MEP Measurement'

                     obj.mep_panel;
                                        
                  
                case 'MEP Hotspot Search'
                     obj.hotspot_panel;
                     
                case 'MEP Motor Threshold Hunting'
                    obj.thresholding_panel;
                    
                case 'fMRI triggered TMS'
                    obj.mrtms_panel;
                    
                case 'MEP Dose Response Curve_sp'
                    obj.ioc_panel;
               
                otherwise
                    
                    disp('other value')
                    
                    
            end
                        obj.info.event.current_measure(obj.info.event.current_measure == ' ') = '_';
                        current_measure=obj.info.event.current_measure
          obj.inputs.mep.target_muscle.String=obj.data.(obj.info.event.current_session).(current_measure).mep.target_muscle


        end
        
        function callback_mrtms_paradigm(obj,src,eventdata)
            mrtms_selected_paradigm=obj.mrtms_panel_stimulation_paradigm.String(obj.mrtms_panel_stimulation_paradigm.Value)
             mrtms_selected_paradigm=mrtms_selected_paradigm{1}
            switch  mrtms_selected_paradigm
                case 'Single Pulse'

                     obj.mrtms_panel;
                                        
                  
                case 'Paired Pulse'
                     obj.mrtms_pp_panel;
                     
                case 'Burst'
                    obj.mrtms_burst_panel;
                    
               
                otherwise
                    
                    disp('other value')
            end
        
        
        end
        
        function rcb_btn(obj,src,eventdata)
            
            
            disp('callback entered')
            
% %                
            obj.bst.inputs.stimuli=[str2num(obj.inputs.mep.stimulation_intensities.String)];
            obj.bst.inputs.iti=[str2num(obj.inputs.mep.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.mep.trials_per_condition.String)];
            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=NaN;
            obj.bst.inputs.mep_amthreshold=NaN;     %active motor (am) threshold in volts %set default
            obj.bst.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.mep.mep_onset.String))/1000];           %mep post trigger onset in seconds %set default
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.mep.mep_offset.String))/1000];          %mep post trigger offset in seconds %set default
            
            
            scope=str2num(obj.inputs.mep.poststim_scope.String)+str2num(obj.inputs.mep.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mep.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.ylim_min=str2num(obj.inputs.mep.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.mep.ylim_max.String)

            obj.bst.best_trialprep;
            
            
            
            obj.bst.data.(obj.bst.info.str).inputs.mep_onset=[(str2num(obj.inputs.mep.mep_onset.String))/1000];           %mep post trigger onset in seconds %set default
            obj.bst.data.(obj.bst.info.str).inputs.mep_offset=[(str2num(obj.inputs.mep.mep_offset.String))/1000];          %mep post trigger offset in seconds %set default
            
            
            scope=str2num(obj.inputs.mep.poststim_scope.String)+str2num(obj.inputs.mep.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mep.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.data.(obj.bst.info.str).inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.data.(obj.bst.info.str).inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;

            obj.bst.data.(obj.bst.info.str).inputs.FontSize=str2num(obj.inputs.mep.FontSize.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_min=str2num(obj.inputs.mep.ylim_min.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_max=str2num(obj.inputs.mep.ylim_max.String)
            
        end
        
        function cb_mep_target_muscle(obj,src,eventdata)
            obj.data.(obj.info.event.current_session).(obj.info.event.current_measure).mep.target_muscle=obj.inputs.mep.target_muscle.String
                   obj.data.(obj.info.event.current_session).(obj.info.event.current_measure).mep.target_muscle=obj.data.(obj.info.event.current_session).(obj.info.event.current_measure).mep.target_muscle{1}

        end
        
        function cb_run_ioc(obj,src,eventdata)
            %             obj.mep_panel_run_btn.Enable='off';
%             obj.mep_panel_update_btn.Enable='on';
%             obj.mep_panel_stop_btn.Enable='on';            

            
            obj.bst.inputs.stimuli=[str2num(obj.inputs.ioc.stimulation_intensities.String)];
            obj.bst.inputs.iti=[str2num(obj.inputs.ioc.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.ioc.trials_per_condition.String)];
            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=NaN;
            obj.bst.inputs.mep_amthreshold=NaN;     
            obj.bst.inputs.mt_method=NaN;           
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.ioc.mep_onset.String))/1000];          
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.ioc.mep_offset.String))/1000];          
            
            
            scope=str2num(obj.inputs.ioc.poststim_scope.String)+str2num(obj.inputs.ioc.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.ioc.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.FontSize=str2num(obj.inputs.ioc.FontSize.String)
            obj.bst.inputs.ylim_min=str2num(obj.inputs.ioc.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.ioc.ylim_max.String)

            
            
            obj.ioc_results;
            obj.bst.best_ioc()
        end
        
                function cb_update_ioc(obj,src,eventdata)
            
            
            disp('callback entered')
            
% %                
            obj.bst.inputs.stimuli=[str2num(obj.inputs.ioc.stimulation_intensities.String)];
            obj.bst.inputs.iti=[str2num(obj.inputs.ioc.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.ioc.trials_per_condition.String)];
            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=NaN;
            obj.bst.inputs.ioc_amthreshold=NaN;     %active motor (am) threshold in volts %set default
            obj.bst.inputs.mt_method=NaN;           %motor thresholding (mt) method in volts %set default
            obj.bst.inputs.ioc_onset=[(str2num(obj.inputs.ioc.mep_onset.String))/1000];           %mep post trigger onset in seconds %set default
            obj.bst.inputs.ioc_offset=[(str2num(obj.inputs.ioc.mep_offset.String))/1000];          %mep post trigger offset in seconds %set default
            
            
            scope=str2num(obj.inputs.ioc.poststim_scope.String)+str2num(obj.inputs.ioc.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.ioc.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.ylim_min=str2num(obj.inputs.ioc.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.ioc.ylim_max.String)

            obj.bst.best_trialprep;
            
            
            
            obj.bst.data.(obj.bst.info.str).inputs.ioc_onset=[(str2num(obj.inputs.ioc.mep_onset.String))/1000];           %mep post trigger onset in seconds %set default
            obj.bst.data.(obj.bst.info.str).inputs.ioc_offset=[(str2num(obj.inputs.ioc.mep_offset.String))/1000];          %mep post trigger offset in seconds %set default
            
            
            scope=str2num(obj.inputs.ioc.poststim_scope.String)+str2num(obj.inputs.ioc.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.ioc.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.data.(obj.bst.info.str).inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.data.(obj.bst.info.str).inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;

            obj.bst.data.(obj.bst.info.str).inputs.ylim_min=str2num(obj.inputs.ioc.ylim_min.String)
            obj.bst.data.(obj.bst.info.str).inputs.FontSize=str2num(obj.inputs.ioc.FontSize.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_min=str2num(obj.inputs.ioc.ylim_min.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_max=str2num(obj.inputs.ioc.ylim_max.String)
            
                end
                
                function cb_update_mt(obj,src,evendata)
                    
                    
            obj.bst.inputs.iti=[str2num(obj.inputs.mt.iti.String)];
            obj.bst.inputs.isi=NaN;
            obj.bst.inputs.trials=[str2num(obj.inputs.mt.trials_per_condition.String)];
            obj.inputs.mt_trialstoavg=[str2num(obj.inputs.mt.trialstoavg.String)];

            obj.bst.inputs.stimunits='MSO';
            obj.bst.inputs.motor_threshold=[str2num(obj.inputs.mt.motor_threshold.String)];
            obj.bst.inputs.mt_method=NaN;           
            obj.bst.inputs.mep_onset=[(str2num(obj.inputs.mt.mep_onset.String))/1000];          
            obj.bst.inputs.mep_offset=[(str2num(obj.inputs.mt.mep_offset.String))/1000];          
            
            
            scope=str2num(obj.inputs.mt.poststim_scope.String)+str2num(obj.inputs.mt.prestim_scope.String);
            scope=scope*5;
            prepostsamples=str2num(obj.inputs.mt.prestim_scope.String)*(-5);
            obj.inputs.sc_samples=scope;
            obj.inputs.sc_prepostsamples=prepostsamples;
            
            obj.bst.inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;
            obj.bst.inputs.sc_samplingrate=5000;
            obj.bst.inputs.stim_mode='MSO';
            
            obj.bst.inputs.FontSize=str2num(obj.inputs.mt.FontSize.String)
            obj.bst.inputs.ylim_min=str2num(obj.inputs.mt.ylim_min.String)
            obj.bst.inputs.ylim_max=str2num(obj.inputs.mt.ylim_max.String)
            
            obj.bst.best_trialprep;
            obj.bst.data.(obj.bst.info.str).inputs.sc_samples=obj.inputs.sc_samples;
            obj.bst.data.(obj.bst.info.str).inputs.sc_prepostsamples=obj.inputs.sc_prepostsamples;

            obj.bst.data.(obj.bst.info.str).inputs.FontSize=str2num(obj.inputs.ioc.FontSize.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_min=str2num(obj.inputs.ioc.ylim_min.String)
            obj.bst.data.(obj.bst.info.str).inputs.ylim_max=str2num(obj.inputs.ioc.ylim_max.String)
            
                end
        
                function stop(obj,src,eventdata)
                   obj.bst.inputs.stimuli=NaN;
            obj.bst.inputs.iti=NaN;
            obj.bst.inputs.isi=NaN;
            obj.bst.best_mep
                end
                
                function opendir(obj,src,eventdata)
                    uigetdir('C:\');
                end
                
                function cb_run_tmsfmri(obj,src,eventdata)
                    obj.info.(obj.info.event.current_session).(obj.info.event.current_measure).counter=obj.info.(obj.info.event.current_session).(obj.info.event.current_measure).counter+1;
                    
                     obj.info.event.current_session={};
            obj.info.event.current_measure={};
                end


    end
end

%% TODO
% 1. Pass on the axes handle to the best toolbox accurately everything is
% dependent over it now

% 2. solve the legend issue

% hardcore issues 1- legend in gui
%% multi-channel MEPs measurements in one protocol