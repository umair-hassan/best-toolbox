classdef best_application < handle
    properties
        par
        bst
        info
        data
        save_buffer
        pr
        pi
        hw
    end
    
    properties (Hidden)
        pmd %panel_measurement_designer
        %         pi  %panel_inputs
        %         pr %panel_results
        %         hw
        var
        grid % bottom most 3 panels
        panel
        pulse
        fig
        menu
        icons
        Date
        %         bst
        %         save_buffer
    end
    
    methods
        %% BEST
        function obj=best_application()
            obj.close_previous;
            obj.create_gui;
            
            function CreateHardwareConfigurationDefaults
                obj.par.hardware_settings.neurone1.device_type=1;
                obj.par.hardware_settings.neurone1.slct_device=1;
                obj.par.hardware_settings.neurone1.device_name='neurone1';
                
            end
        end
        function close_previous(obj)
            close all;
            ClassExist=exist('best_application','class');
            if ClassExist==8
                baseVariables = evalin('base' , 'whos');
                for i = 1:length(baseVariables)
                    if (strcmpi(baseVariables(i).class , 'best_application'))
                        evalin( 'base', ['clear(''' baseVariables(i).name ''')'] )
                    end
                end
            end
        end
        function create_gui(obj)
            obj.create_best_obj;
            obj.create_figure;
            obj.create_menu;
            obj.create_main_panel;
            obj.create_inputs_panel;
            obj.create_results_panel;
            obj.create_hwcfg_panel;
            %              obj.pi_ioc
            %             obj.results_panel;
            % obj.pr.axesno=6;
            % obj.resultsPanel
            
            
            
        end
        function create_best_obj(obj)
            obj.bst= best_toolbox (obj);
            %              obj.bst= best_toolbox_gui_version_inprogress_testinlab_2910_sim (obj);
        end
        function create_figure(obj)
            obj.fig.handle = figure('Tag','BESTToolboxApplication','ToolBar','none','MenuBar','none','Name','BEST Toolbox','NumberTitle','off','CloseRequestFcn',@obj.close_figure_ioio);
            
            obj.info.session_no=0;
            obj.info.measurement_no=0;
            obj.info.event.current_session={};
            obj.info.event.current_measure={};
            obj.info.session_matrix={};
            
            %             set(obj.fig.handle, 'Position', get(0, 'Screensize'));
            set(obj.fig.handle,'Units','normalized', 'Position', [0 0 1 0.97]);
            
            obj.info.pause=0;
            obj.info.session_copy_id=0;
            obj.info.measurement_paste_marker=0;
            obj.info.copy_index=0;
            
            obj.pi.mm.stim.no=0;
            
            % save icons graphical data into dedicated object here
            obj.icons.stimulator=imread('best_icon_stimulator.png');
            obj.icons.single_pulse=imread('best_icon_single_pulse.png');
            obj.icons.paired_pulse=imread('best_icon_paired_pulse.png');
            obj.icons.train=imread('best_icon_train_pulse.png');
            
        end
        function close_figure_ioio(obj,~,~)
            obj.cb_menu_save;
            answer = questdlg('Do you want to Close BEST Toolbox Application current Session?','BEST Toolbox','No','Yes Close','No');
            switch answer
                case 'Yes Close'
                    delete (findobj('Tag','BESTToolboxApplication'));
                case 'No'
                    return
            end
        end
        function create_menu(obj)
            
            obj.fig.vbox=uix.VBox( 'Parent', obj.fig.handle, 'Spacing', 5, 'Padding', 5  );
            obj.fig.menu=uix.Panel( 'Parent',obj.fig.vbox, 'Padding', 1);
            menu_hbox=uix.HBox('Parent',obj.fig.menu,'Spacing', 5  );
            obj.menu.load.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Load','FontWeight','Bold','Callback',@(~,~)obj.cb_menu_load );
            obj.menu.save.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Save','FontWeight','Bold','Callback',@(~,~)obj.cb_menu_save);
            %             obj.menu.subjdata.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Subject Data','FontWeight','Bold' );
            obj.menu.md.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Close Controller','FontWeight','Bold' ,'Callback', @(~,~)obj.cb_menu_md);
            obj.menu.ip.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Close Designer','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_ip );
            obj.menu.rp.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Close Results','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_rp );
            obj.menu.hwcfg.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Open Hardware Config','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_hwcfg ); %TODO1
            obj.menu.settings.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Open Settings','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_settings ); %TODO1
            obj.menu.notes.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Notes','FontWeight','Bold','Callback', @(~,~)obj.cb_notes );
            uiextras.HBox( 'Parent', menu_hbox,'Spacing', 5, 'Padding', 5 );
            set(menu_hbox,'Widths',[-0.6 -0.6 -1.5 -1.5 -1.5 -1.8 -1.8 -1.5 -12]);
            
            
            obj.info.menu.md=0;
            obj.info.menu.ip=0;
            obj.info.menu.rp=0;
            obj.info.menu.hwcfg=0;
            
            
        end
        function create_main_panel(obj)
            obj.fig.main = uix.GridFlex( 'Parent', obj.fig.vbox, 'Spacing', 5 );
            set(obj.fig.vbox,'Heights',[-1 -25]);
            p_measurement_designer = uix.Panel( 'Parent', obj.fig.main, 'Padding', 5,  'Units','normalized','BorderType','none');
            obj.pmd.panel = uix.Panel( 'Parent', p_measurement_designer, 'Title', 'Experiment Controller', 'Padding', 5,'FontSize',14 ,'Units','normalized','FontWeight','bold','TitlePosition','centertop');
            pmd_vbox = uix.VBox( 'Parent', obj.pmd.panel, 'Spacing', 5, 'Padding', 5  );
            
            % experiment title: first horizontal row in measurement designer panel
            pmd_hbox_exp_title = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_exp_title,'String','Experiment Title:','FontSize',11,'HorizontalAlignment','left','Units','normalized' );
            obj.pmd.exp_title.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_exp_title ,'String','Experiment1','FontSize',11,'Callback',@(~,~)obj.cb_pmd_exp_title_editfield);
            obj.pmd.exp_title.btn=uicontrol( 'Parent', pmd_hbox_exp_title ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir );
            set( pmd_hbox_exp_title, 'Widths', [120 -0.7 -0.09]);
            
            % subject code: second horizontal row on first panel
            pmd_hbox_sub_code = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_sub_code,'String','Subject Code:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pmd.sub_code.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_sub_code ,'String','Subject1','FontSize',11,'Callback',@(~,~)obj.cb_pmd_sub_code_editfield);
            obj.pmd.sub_code.btn=uicontrol( 'Parent', pmd_hbox_sub_code ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir );
            set( pmd_hbox_sub_code, 'Widths', [120 -0.7 -0.09]);
            
            % session title edit box: third horizontal row on first panel
            pmd_hbox_session_title = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_session_title,'String','Session Title:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            obj.pmd.sess_title.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_session_title ,'FontSize',11);
            obj.pmd.sess_title.btn=uicontrol( 'Parent', pmd_hbox_session_title ,'Style','PushButton','String','+','FontWeight','Bold','Callback',@(~,~)obj.cb_session_add);
            set( pmd_hbox_session_title, 'Widths', [120 -0.7 -0.09]);
            
            % drop-down select measure: fourth horizontal row on first panel
            pmd_hbox_slct_mes = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_slct_mes,'String','Select Protocol:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            obj.pmd.select_measure.string={'MEP Hotspot Search','MEP Motor Threshold Hunting','MEP Dose Response Curve','MEP Measurement','rsEEG Measurement','Sensory Threshold Hunting','rTMS Intervention','TEP Hotspot Search','TEP Measurement','ERP Measurement','TMS fMRI'};
            obj.pmd.select_measure.popupmenu=uicontrol( 'Style','popupmenu','Parent', pmd_hbox_slct_mes ,'FontSize',11,'String',obj.pmd.select_measure.string);
            obj.pmd.select_measure.btn=uicontrol( 'Parent', pmd_hbox_slct_mes ,'Style','PushButton','String','+','FontWeight','Bold','Callback',@(~,~)obj.cb_measure_add);
            set( pmd_hbox_slct_mes, 'Widths', [120 -0.7 -0.09]);
            
            % empty fifth horizontal row on first panel
            fifth_row = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', fifth_row,'String','','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            uicontrol( 'Style','text','Parent', fifth_row ,'FontSize',11,'String','');
            uicontrol( 'Parent', fifth_row ,'Style','text','String','','FontWeight','Bold')
            set( fifth_row, 'Widths', [120 -0.7 -0.05]);
            
            % text session: sixth horizontal row on first panel
            uicontrol( 'Style','text','Parent', pmd_vbox,'String','Sessions','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            % sessions listbox: seventh horizontal row on first panel
            obj.pmd.lb_sessions.string={};
            m_sessions=uicontextmenu(obj.fig.handle);
            mus1 = uimenu(m_sessions,'label','Copy','Callback',@(~,~)obj.cb_pmd_lb_sessions_copy);
            %             mus2 = uimenu(m_sessions,'label','Paste Above','Callback',@(~,~)obj.cb_pmd_lb_sessions_pasteup);
            mus3 = uimenu(m_sessions,'label','Paste','Callback',@(~,~)obj.cb_pmd_lb_sessions_pastedown);
            mus4 = uimenu(m_sessions,'label','Delete','Callback',@(~,~)obj.cb_pmd_lb_sessions_del);
            mus5 = uimenu(m_sessions,'label','Move Up','Callback',@(~,~)obj.cb_pmd_lb_sessions_moveup);
            mus5 = uimenu(m_sessions,'label','Move Down','Callback',@(~,~)obj.cb_pmd_lb_sessions_movedown);
            mus7 = uimenu(m_sessions,'label','Rename Sesion','Callback',@(~,~)obj.cb_session_rename);
            
            obj.pmd.lb_sessions.listbox=uicontrol( 'Style','listbox','Parent', pmd_vbox ,'KeyPressFcn',@(~,~)obj.cb_pmd_lb_session_keypressfcn,'FontSize',11,'String',obj.pmd.lb_sessions.string,'uicontextmenu',m_sessions,'Callback',@(~,~)obj.cb_session_listbox);
            
            %empty 8th horizontal row on first panel
            uicontrol( 'Style','text','Parent', pmd_vbox,'String','Protocols','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            %measurement listbox: 9th horizontal row on first panel
            ProtocolListBox = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 0, 'Padding', 0  );
            ProtocolListBox = uiextras.GridFlex( 'Parent', ProtocolListBox, 'Spacing', 5, 'Padding', 5  );
            %             measure_lb2={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','Dose-Response Curve (MEP-sp)','Dose-Response Curve (MEP-pp)','EEG triggered TMS','MR triggered TMS','TEP Measurement'};
            obj.pmd.lb_measures.string={};
            m=uicontextmenu(obj.fig.handle);
            mu1 = uimenu(m,'label','Copy','Callback',@(~,~)obj.cb_pmd_lb_measures_copy);
            %             mu2 = uimenu(m,'label','Paste Above','Callback',@(~,~)obj.cb_pmd_lb_measures_pasteup);
            mu3 = uimenu(m,'label','Paste','Callback',@(~,~)obj.cb_pmd_lb_measures_pastedown);
            mu4 = uimenu(m,'label','Delete','Callback',@(~,~)obj.cb_pmd_lb_measures_del);
            mu7 = uimenu(m,'label','Add Suffix','Callback',@(~,~)obj.cb_measure_suffix);
            mu5 = uimenu(m,'label','Move Up','Callback',@(~,~)obj.cb_pmd_lb_measures_moveup);
            mu6 = uimenu(m,'label','Move Down','Callback',@(~,~)obj.cb_pmd_lb_measures_movedown);
            obj.pmd.lb_measure_menu_loadresults=uimenu(m,'label','Load Results','Callback',@(~,~)obj.cb_pmd_lb_measure_menu_loadresult);
            mu8 = uimenu(m,'label','Rename Protocol','Callback',@(~,~)obj.cb_measure_rename);
            
            obj.pmd.lb_measures.listbox=uicontrol( 'Style','listbox','Parent', ProtocolListBox ,'KeyPressFcn',@(~,~)obj.cb_pmd_lb_measure_keypressfcn,'FontSize',11,'String',obj.pmd.lb_measures.string,'uicontextmenu',m,'Callback',@(~,~)obj.cb_measure_listbox);
            obj.pmd.ProtocolStatus.listbox=uicontrol( 'Style','listbox','Parent', ProtocolListBox ,'FontAngle','italic','KeyPressFcn',@(~,~)obj.cb_pmd_lb_measure_keypressfcn,'FontSize',11,'String',obj.pmd.lb_measures.string,'uicontextmenu',m,'Callback',@(~,~)obj.cb_measure_listbox);
            ProtocolListBox.ColumnSizes=[-2 -1];
            m=uicontextmenu(obj.fig.handle);
            
            LastRow = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            obj.pmd.CompileButton=uicontrol( 'Parent', LastRow ,'Style','PushButton','String','Compile','Enable','off','FontWeight','Bold','Callback',@obj.CompileButton);
            obj.pmd.RunStopButton=uicontrol( 'Parent', LastRow ,'Style','PushButton','String','Run','Enable','off','FontWeight','Bold','Callback',@obj.RunStopButton);
            obj.pmd.PauseUnpauseButton=uicontrol( 'Parent', LastRow ,'Style','PushButton','String','Pause','Enable','off','FontWeight','Bold','Callback',@obj.PauseUnpauseButton);
            
            set( pmd_vbox, 'Heights', [35 35 35 35 0 -0.04 -0.11 -0.04 -0.63 45]);
            
            
            
        end
        %% Run Stop Controllers
        function CompileButton(obj,~,~)
            try
                obj.bst.best_compile;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'compiled'};
                obj.cb_measure_listbox;
            catch e
                errordlg('This Protcol has been stopped due to an error. Check your input parameters and MATLAB command line.','BEST Toolbox');
                fprintf(1,'The identifier was:\n%s',e.identifier);
                fprintf(1,'\nThere was an error! The message was:\n%s',e.message);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'Error'};
                obj.pmd.ProtocolStatus.listbox.String(obj.pmd.ProtocolStatus.listbox.Value)={'Error'};
                obj.enable_listboxes;
            end
        end
        function RunStopButton(obj,~,~)
            try
                if strcmp(obj.pmd.RunStopButton.String,'Stop')
                    uiresume;
                    obj.bst.inputs.stop_event=1;
                    obj.pmd.RunStopButton.Enable='off';
                    obj.pmd.PauseUnpauseButton.Enable='off';
                    obj.pmd.RunStopButton.String='Run';
                    obj.pmd.PauseUnpauseButton.String='Pause';
                    obj.enable_listboxes;
                    if ~isempty(obj.bst.bossbox), obj.bst.bossbox.stop; end
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'Stopped'};
                    obj.pmd.ProtocolStatus.listbox.String(obj.pmd.ProtocolStatus.listbox.Value)={'Stopped'};
                elseif strcmp(obj.pmd.RunStopButton.String,'Run') % && strcmp(obj.pmd.RunStopButton.Enable,'On')
                    obj.fig.main.Widths(1)=-1.15;
                    obj.fig.main.Widths(2)=0;
                    obj.fig.main.Widths(3)=-3.35;
                    obj.pmd.RunStopButton.String='Stop';
                    obj.pmd.PauseUnpauseButton.Enable='on';
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'Executing'};
                    obj.pmd.ProtocolStatus.listbox.String(obj.pmd.ProtocolStatus.listbox.Value)={'Executing'};
                    %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1}='off';
                    obj.disable_listboxes;
                    %search for all the handles and make their enable off uicontrols, table and the interactive axes  %https://www.mathworks.com/help/matlab/ref/disabledefaultinteractivity.html
                    %make enable off in the listboxes and all pmd fields
                    pause(0.02); %Test it by replacing it with drawnow
                    switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Protocol{1,1}
                        case 'MEP Hotspot Search Protocol'
                            switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolMode
                                case 1 %Automated
                                    ParametersFieldNames=fieldnames(obj.pi.hotspot);
                                    for iLoadingParameters=1:numel(ParametersFieldNames)
                                        obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                                    end
                                    obj.bst.best_hotspot
                                case 2 %Manual
                                    obj.bst.best_hotspot_manual
                            end
                        case 'MEP Measurement Protocol'
                            obj.bst.best_mep;
                        case 'MEP Dose Response Curve Protocol'
                            obj.bst.best_drc;
                        case 'Motor Threshold Hunting Protocol'
                            obj.bst.best_mth;
                        case 'Psychometric Threshold Hunting Protocol'
                            obj.bst.best_psychmth;
                        case 'rTMS Intervention Protocol'
                            obj.bst.best_rtms;
                        case 'rs EEG Measurement Protocol'
                            obj.bst.best_rseeg;
                        case 'TEP Hotspot Search Protocol'
                            switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolMode
                                case 1 %Automated
                                    ParametersFieldNames=fieldnames(obj.pi.tephs);
                                    for iLoadingParameters=1:numel(ParametersFieldNames)
                                        obj.pi.tephs.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                                    end
                                    obj.bst.best_tephs
                                case 2 %Manual
                                    obj.bst.best_tephs_manual
                            end
                        case 'ERP Measurement Protocol'
                            obj.bst.best_erp;
                        case 'TMS fMRI Protocol'
                            obj.tmsfmri_run
                    end
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'Successful'};
                    obj.pmd.ProtocolStatus.listbox.String(obj.pmd.ProtocolStatus.listbox.Value)={'Successful'};
                end
            catch e
                errordlg('This Protcol has been stopped due to an error. Check your input parameters and MATLAB command line.','BEST Toolbox');
                fprintf(1,'The identifier was:\n%s',e.identifier);
                fprintf(1,'\nThere was an error! The message was:\n%s',e.message);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'Error'};
                obj.pmd.ProtocolStatus.listbox.String(obj.pmd.ProtocolStatus.listbox.Value)={'Error'};
                obj.enable_listboxes;
                rethrow(e)
            end
        end
        function PauseUnpauseButton(obj,~,~)
            obj.pmd.RunStopButton.String='Stop';
            obj.pmd.PauseUnpauseButton.Enable='on';
            if strcmp(obj.pmd.PauseUnpauseButton.String,'Pause') && ~strcmp(obj.info.event.current_measure,'rsEEG Measurement')
                obj.pmd.PauseUnpauseButton.String='Unpause';
                uiwait;
            elseif strcmp(obj.pmd.PauseUnpauseButton.String,'Unpause')
                obj.pmd.PauseUnpauseButton.String='Pause';
                uiresume;
            end
        end
        function DisableInteractivity(obj)
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                end
            end
            
            switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Protocol{1,1}
                case 'MEP Hotspot Search Protocol'
                    
                case 'MEP Measurement Protocol'
            end
        end
        
        function disable_listboxes(obj)
            obj.pmd.lb_measures.listbox.Enable='off';
            obj.pmd.lb_sessions.listbox.Enable='off';
            obj.pmd.ProtocolStatus.listbox.Enable='off';
        end
        function enable_listboxes(obj)
            obj.pmd.lb_measures.listbox.Enable='on';
            obj.pmd.lb_sessions.listbox.Enable='on';
            obj.pmd.ProtocolStatus.listbox.Enable='on';
        end
        
        function cb_pmd_lb_session_keypressfcn(obj)
            if (numel(obj.pmd.lb_sessions.listbox.String)==0 || obj.pmd.lb_sessions.listbox.Value==0)
                return
            else
                value = double(get(gcf,'CurrentCharacter'));
                if(value==117)
                    obj.cb_pmd_lb_sessions_moveup
                elseif(value==100)
                    obj.cb_pmd_lb_sessions_movedown
                end
            end
            
        end
        function cb_pmd_lb_measure_keypressfcn(obj)
            if (numel(obj.pmd.lb_measures.listbox.String)==0 || obj.pmd.lb_measures.listbox.Value==0)
                return
            else
                value = double(get(gcf,'CurrentCharacter'));
                if(value==117)
                    obj.cb_pmd_lb_measures_moveup
                elseif(value==100)
                    obj.cb_pmd_lb_measures_movedown
                end
            end
            
        end
        function cb_pmd_exp_title_editfield(obj)
            if(isvarname(obj.pmd.exp_title.editfield.String)==0)
                errordlg('Experiment Title is an invalid string. Characters found in your string are not allowed by your operating system as filename. Please use a meaningful string that is not starting with a numeric character or space charachet and do not contain any special characters to proceed.','BEST Toolbox');
                obj.pmd.exp_title.editfield.String=[];
                return
            end
        end
        function cb_pmd_lb_sessions_del(obj)
            if (numel(obj.pmd.lb_sessions.listbox.String)==0 || obj.pmd.lb_sessions.listbox.Value==0)
                return
            else
                answer = questdlg('If you want to delete this session, the data saved associated with this session will also be deleted, press DELETE to continue.','BEST Toolbox','Return','DELETE','Return');
                switch answer
                    case 'DELETE'
                        selected_session=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value);
                        selected_session=selected_session{1};
                        obj.par.(selected_session)=[];
                        obj.bst.sessions.(selected_session)=[];
                        obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value)=[];
                        obj.pmd.lb_sessions.string(obj.pmd.lb_sessions.listbox.Value)=[];
                        obj.data.(selected_session)=[];
                        obj.info.session_no=obj.info.session_no-1;
                        obj.pmd.lb_sessions.listbox.String=obj.info.session_matrix;
                        if(obj.info.session_no~=0)
                            obj.pmd.lb_sessions.listbox.Value=1;
                        else
                            return;
                        end
                        obj.cb_session_listbox
                    case 'Return'
                        return
                end
            end
            % summary of above steps
            % find the value of listbox
            % get the session name from the session listbox
            % delete that from the par
            % delete that from the bst
            % delete that from anywhere in the listavailable
            % minue one the session number
            % update the session to be first one
            % update the current session to be first one
            
        end
        function cb_pmd_lb_sessions_copy(obj)
            if (numel(obj.pmd.lb_sessions.listbox.String)==0 || obj.pmd.lb_sessions.listbox.Value==0)
                return
            else
                obj.info.session_copy_id=obj.info.session_copy_id+1;
                obj.info.session_copied=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value);
            end
        end
        function cb_pmd_lb_sessions_pasteup(obj)
            if (obj.info.session_copy_id==0 || isempty(obj.info.session_copied)==1)
                errordlg('No Session is copied, if you are trying to paste already pasted session, please copy it again.','BEST Toolbox');
                return
            else
                if(obj.pmd.lb_sessions.listbox.Value-1~=0)
                    paste_value=obj.pmd.lb_sessions.listbox.Value-1;
                else
                    return;
                end
                obj.info.session_matrix_copybuffer(1,obj.info.session_copy_id)=obj.info.session_copied;
                obj.info.session_copied=obj.info.session_copied{1};
                if any(strcmp(obj.info.session_matrix_copybuffer,obj.info.session_copied))
                    idx_exist=find(strcmp(obj.info.session_matrix_copybuffer, obj.info.session_copied));
                    idx_exist=num2str(numel(idx_exist));
                    new_session=obj.info.session_copied;
                    new_session=[new_session '_' 'copy' '_' idx_exist];
                    idx_exist=[];
                else
                    
                    new_session=obj.info.session_copied;
                    new_session=[new_session '_' 'copy'];
                end
                
                
                try
                    obj.par.(new_session)=obj.par.(obj.info.session_copied);
                catch
                end
                
                index=obj.pmd.lb_sessions.listbox.Value;
                str_a=obj.info.session_matrix(1:index-1);
                str_b=new_session;
                str_c=obj.info.session_matrix(index:numel(obj.info.session_matrix));
                
                obj.info.session_matrix=[str_a str_b str_c];
                obj.pmd.lb_sessions.string=obj.info.session_matrix;
                obj.pmd.lb_sessions.listbox.String=obj.info.session_matrix;
                obj.pmd.lb_sessions.listbox.Value=paste_value;
                obj.info.sessoin_no=obj.info.session_no+1;
                obj.data.(new_session)=obj.data.(obj.info.session_copied);
                
                for i=1:numel(obj.data.(obj.info.session_copied).info.measurement_str_to_listbox)
                    obj.info.event.current_session=new_session;
                    obj.info.event.current_measure_fullstr=obj.data.(new_session).info.measurement_str_to_listbox(i);
                    obj.info.event.current_measure_fullstr=obj.info.event.current_measure_fullstr{1};
                    obj.info.event.current_measure_fullstr(obj.info.event.current_measure_fullstr == ' ') = '_';
                    obj.info.event.current_measure=obj.data.(new_session).info.measurement_str(i);
                    obj.info.event.current_measure=obj.info.event.current_measure{1};
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1}='on';
                end
                
                obj.info.session_copied=[];
                obj.info.session_no=obj.info.session_no+1;
                obj.cb_session_listbox;
                
            end
        end
        function cb_pmd_lb_sessions_pastedown(obj)
            if (obj.info.session_copy_id==0|| isempty(obj.info.session_copied)==1)
                errordlg('No Session is copied, if you are trying to paste already pasted session, please copy it again.','BEST Toolbox');
                return
            else
                paste_value=obj.pmd.lb_sessions.listbox.Value+1;
                obj.info.session_matrix_copybuffer(1,obj.info.session_copy_id)=obj.info.session_copied;
                obj.info.session_copied=obj.info.session_copied{1};
                if any(strcmp(obj.info.session_matrix_copybuffer,obj.info.session_copied))
                    idx_exist=find(strcmp(obj.info.session_matrix_copybuffer, obj.info.session_copied));
                    idx_exist=num2str(numel(idx_exist));
                    new_session=obj.info.session_copied;
                    new_session=[new_session '_' 'copy' '_' idx_exist];
                    idx_exist=[];
                else
                    new_session=obj.info.session_copied;
                    new_session=[new_session '_' 'copy'];
                end
                
                try
                    obj.par.(new_session)=obj.par.(obj.info.session_copied);
                catch
                end
                
                index=obj.pmd.lb_sessions.listbox.Value;
                str_a=obj.info.session_matrix(1:index);
                str_b=new_session;
                str_c=obj.info.session_matrix(index+1:numel(obj.info.session_matrix));
                
                obj.info.session_matrix=[str_a str_b str_c];
                obj.pmd.lb_sessions.string=obj.info.session_matrix;
                obj.pmd.lb_sessions.listbox.String=obj.info.session_matrix;
                obj.pmd.lb_sessions.listbox.Value=paste_value;
                obj.info.sessoin_no=obj.info.session_no+1;
                obj.data.(new_session)=obj.data.(obj.info.session_copied);
                
                for i=1:numel(obj.data.(obj.info.session_copied).info.measurement_str_to_listbox)
                    obj.info.event.current_session=new_session;
                    obj.info.event.current_measure_fullstr=obj.data.(new_session).info.measurement_str_to_listbox(i);
                    obj.info.event.current_measure_fullstr=obj.info.event.current_measure_fullstr{1};
                    obj.info.event.current_measure_fullstr(obj.info.event.current_measure_fullstr == ' ') = '_';
                    obj.info.event.current_measure=obj.data.(new_session).info.measurement_str(i);
                    obj.info.event.current_measure=obj.info.event.current_measure{1};
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1}='on';
                end
                
                obj.info.session_copied=[];
                obj.info.session_no=obj.info.session_no+1;
                obj.cb_session_listbox;
                
            end
        end
        function cb_pmd_lb_sessions_moveup(obj)
            if (numel(obj.pmd.lb_sessions.listbox.String)==0 || obj.pmd.lb_sessions.listbox.Value==0)
                return
            else
                if(numel(obj.pmd.lb_sessions.listbox.String)>1 && obj.pmd.lb_sessions.listbox.Value~=1)
                    moveup_session=obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value);
                    movedown_session=obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value-1);
                    obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value-1)=moveup_session;
                    obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value)=movedown_session;
                    obj.pmd.lb_sessions.string=obj.info.session_matrix;
                    obj.pmd.lb_sessions.listbox.String=obj.info.session_matrix;
                    obj.pmd.lb_sessions.listbox.Value=obj.pmd.lb_sessions.listbox.Value-1;
                    moveup_session=[];
                    movedown_session=[];
                    obj.cb_session_listbox
                else
                    return
                end
            end
            
        end
        function cb_pmd_lb_sessions_movedown(obj)
            if (numel(obj.pmd.lb_sessions.listbox.String)==0 || obj.pmd.lb_sessions.listbox.Value==0)
                return
            else
                if(numel(obj.pmd.lb_sessions.listbox.String)>1 && obj.pmd.lb_sessions.listbox.Value<obj.info.session_no)
                    moveup_session=obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value+1);
                    movedown_session=obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value);
                    obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value)=moveup_session;
                    obj.info.session_matrix(obj.pmd.lb_sessions.listbox.Value+1)=movedown_session;
                    obj.pmd.lb_sessions.string=obj.info.session_matrix;
                    obj.pmd.lb_sessions.listbox.String=obj.info.session_matrix;
                    obj.pmd.lb_sessions.listbox.Value=obj.pmd.lb_sessions.listbox.Value+1;
                    moveup_session=[];
                    movedown_session=[];
                    obj.cb_session_listbox
                else
                    return
                end
            end
            
        end
        function cb_pmd_lb_measures_del(obj)
            
            if(numel(obj.pmd.lb_measures.listbox.String)==0 || obj.pmd.lb_measures.listbox.Value==0)
                return
            else
                answer = questdlg('If you want to delete this measurement, the data saved associated with this measurement will also be deleted, press DELETE to continue.','BEST Toolbox','Return','DELETE','Return');
                switch answer
                    case 'DELETE'
                        obj.info.event.current_session
                        obj.info.event.current_measure_fullstr
                        
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr)=[];
                        obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr)=[];
                        obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value)=[];
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value)=[];
                        obj.data.(obj.info.event.current_session).info.measurement_str_original(obj.pmd.lb_measures.listbox.Value)=[];
                        obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no-1;
                        obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
                        if(obj.data.(obj.info.event.current_session).info.measurement_no~=0)
                            obj.pmd.lb_measures.listbox.Value=1;
                        else
                            return;
                        end
                        obj.cb_measure_listbox
                    case 'Return'
                        return
                end
            end
        end
        function cb_pmd_lb_measures_copy(obj)
            if(numel(obj.pmd.lb_measures.listbox.String)==0 || obj.pmd.lb_measures.listbox.Value==0)
                return
            else
                obj.data.meas_copied=obj.pmd.lb_measures.listbox.String(obj.pmd.lb_measures.listbox.Value);
                obj.data.meas_copied_orignial=obj.data.(obj.info.event.current_session).info.measurement_str_original(obj.pmd.lb_measures.listbox.Value);
                obj.data.copied_frm_session=obj.info.event.current_session;
                obj.info.copy_index=obj.info.copy_index+1;
            end
        end
        function cb_pmd_lb_measures_pasteup(obj)
            if(obj.info.copy_index<1 || isempty(obj.data.meas_copied)==1)
                errordlg('No Measurement is copied, if you are trying to paste already pasted measurement, please copy it again.','BEST Toolbox');
                return
            else
                
                
                if(obj.pmd.lb_measures.listbox.Value-1>=0)
                    if(obj.pmd.lb_measures.listbox.Value-1==0)
                        paste_value=obj.pmd.lb_measures.listbox.Value;
                    else
                        paste_value=obj.pmd.lb_measures.listbox.Value-1;
                    end
                else
                    return;
                end
                obj.data.(obj.info.event.current_session).info.meas_copy_id=obj.data.(obj.info.event.current_session).info.meas_copy_id+1;
                
                obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer(1,obj.data.(obj.info.event.current_session).info.meas_copy_id)=obj.data.meas_copied;
                
                any(strcmp(obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer,obj.data.meas_copied))
                if any(strcmp(obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer,obj.data.meas_copied))
                    idx_exist=find(strcmp(obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer,obj.data.meas_copied));
                    idx_exist=num2str(numel(idx_exist));
                    new_session=obj.data.meas_copied{1};
                    new_session=[new_session '_' 'copy' '_' idx_exist];
                    idx_exist=[];
                else
                    new_session=obj.data.meas_copied;
                    new_session=[new_session '_' 'copy'];
                end
                try
                    new_session_forpar=new_session;
                    new_session_forpar(new_session_forpar == ' ') = '_';
                    meas_copied=obj.data.meas_copied{1};
                    meas_copied(meas_copied == ' ') = '_';
                    obj.par.(obj.info.event.current_session).(new_session_forpar)=obj.par.(obj.data.copied_frm_session).(meas_copied);
                catch
                    disp('error at cb_pmd_lb_measures_pasteup')
                end
                index=obj.pmd.lb_measures.listbox.Value;
                
                switch numel(obj.pmd.lb_measures.listbox.String)
                    case 0
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox={new_session};
                        obj.data.meas_copied_orignial
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox
                        obj.data.(obj.info.event.current_session).info.measurement_str=obj.data.meas_copied_orignial;
                        obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.meas_copied_orignial;
                        obj.pmd.lb_measures.listbox.Value=1;
                        
                    case 1
                        str_b=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1);
                        str_a=new_session;
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b];
                        str_b=obj.data.(obj.info.event.current_session).info.measurement_str_original(1);
                        str_a=obj.data.meas_copied_orignial;
                        obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b];
                        obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b];
                        obj.pmd.lb_measures.listbox.Value=1;
                        
                    otherwise
                        if(obj.pmd.lb_sessions.listbox.Value>1)
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1:index-1);
                            str_b=new_session;
                            str_c=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(index:numel(obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox));
                            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b str_c];
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_original(1:index-1);
                            str_b=obj.data.meas_copied_orignial;
                            str_c=obj.data.(obj.info.event.current_session).info.measurement_str_original(index:numel(obj.data.(obj.info.event.current_session).info.measurement_str_original));
                            obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b str_c];
                            obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b str_c];
                            obj.pmd.lb_measures.listbox.Value=paste_value;
                            
                        else
                            str_b=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1:index);
                            str_a=new_session;
                            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b];
                            str_b=obj.data.(obj.info.event.current_session).info.measurement_str_original(1:index);
                            str_a=obj.data.meas_copied_orignial;
                            obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b];
                            obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b];
                            obj.pmd.lb_measures.listbox.Value=paste_value;
                            
                        end
                end
                obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
                obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no+1;
                obj.data.meas_copied=[];
                obj.info.event.current_measure_fullstr=new_session_forpar;
                obj.info.event.current_measure=obj.data.meas_copied_orignial;
                obj.info.event.current_measure=obj.info.event.current_measure{1};
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1}='on';
                obj.cb_measure_listbox;
            end
        end
        function cb_pmd_lb_measures_pastedown(obj)
            if(obj.info.copy_index<1|| isempty(obj.data.meas_copied)==1)
                errordlg('No Measurement is copied, if you are trying to paste already pasted measurement, please copy it again.','BEST Toolbox');
                return
            else
                
                obj.data.(obj.info.event.current_session).info.meas_copy_id=obj.data.(obj.info.event.current_session).info.meas_copy_id+1;
                paste_value=obj.pmd.lb_measures.listbox.Value+1;
                obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer(1,obj.data.(obj.info.event.current_session).info.meas_copy_id)=obj.data.meas_copied;
                if any(strcmp(obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer,obj.data.meas_copied))
                    idx_exist=find(strcmp(obj.data.(obj.info.event.current_session).info.meas_matrix_copybuffer,obj.data.meas_copied));
                    idx_exist=num2str(numel(idx_exist));
                    new_session=obj.data.meas_copied{1};
                    new_session=[new_session '_' 'copy' '_' idx_exist];
                    idx_exist=[];
                else
                    new_session=obj.data.meas_copied;
                    new_session=[new_session '_' 'copy'];
                end
                try
                    new_session_forpar=new_session;
                    new_session_forpar(new_session_forpar == ' ') = '_';
                    meas_copied=obj.data.meas_copied{1};
                    meas_copied(meas_copied == ' ') = '_';
                    obj.par.(obj.info.event.current_session).(new_session_forpar)=obj.par.(obj.data.copied_frm_session).(meas_copied);
                catch
                    disp('error at cb_pmd_lb_measures_pastedown')
                end
                index=obj.pmd.lb_measures.listbox.Value;
                switch numel(obj.pmd.lb_measures.listbox.String)
                    case 0
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox={new_session};
                        obj.data.meas_copied_orignial
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox
                        obj.data.(obj.info.event.current_session).info.measurement_str=obj.data.meas_copied_orignial;
                        obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.meas_copied_orignial;
                        obj.pmd.lb_measures.listbox.Value=1;
                        
                    case 1
                        str_a=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1);
                        str_b=new_session;
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b];
                        str_a=obj.data.(obj.info.event.current_session).info.measurement_str_original(1);
                        str_b=obj.data.meas_copied_orignial;
                        obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b];
                        obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b];
                        obj.pmd.lb_measures.listbox.Value=2;
                        
                    otherwise
                        if(obj.pmd.lb_sessions.listbox.Value<(numel(obj.pmd.lb_measures.listbox.String)))
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1:index);
                            str_b=new_session;
                            str_c=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(index+1:numel(obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox));
                            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b str_c];
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_original(1:index);
                            str_b=obj.data.meas_copied_orignial;
                            str_c=obj.data.(obj.info.event.current_session).info.measurement_str_original(index+1:numel(obj.data.(obj.info.event.current_session).info.measurement_str_original));
                            obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b str_c];
                            obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b str_c];
                            obj.pmd.lb_measures.listbox.Value=paste_value;
                            
                        else
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1:index);
                            str_b=new_session;
                            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox=[str_a str_b];
                            str_a=obj.data.(obj.info.event.current_session).info.measurement_str_original(1:index);
                            str_b=obj.data.meas_copied_orignial;
                            obj.data.(obj.info.event.current_session).info.measurement_str=[str_a str_b];
                            obj.data.(obj.info.event.current_session).info.measurement_str_original=[str_a str_b];
                            obj.pmd.lb_measures.listbox.Value=paste_value;
                            
                        end
                end
                obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
                obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no+1;
                obj.data.meas_copied=[];
                obj.info.event.current_measure_fullstr=new_session_forpar;
                obj.info.event.current_measure=obj.data.meas_copied_orignial;
                obj.info.event.current_measure=obj.info.event.current_measure{1};
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1}='on';
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolStatus={'created'};
                obj.cb_measure_listbox;
            end
        end
        function cb_pmd_lb_measures_moveup(obj)
            if(numel(obj.pmd.lb_measures.listbox.String)==0 || obj.pmd.lb_measures.listbox.Value==0)
                return
            else
                if(numel(obj.pmd.lb_measures.listbox.String)>1 && obj.pmd.lb_measures.listbox.Value~=1)
                    moveup_session=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value);
                    movedown_session=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value-1);
                    obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value-1)=moveup_session;
                    obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value)=movedown_session;
                    obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
                    
                    
                    moveup_session=obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value);
                    movedown_session=obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value-1);
                    obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value-1)=moveup_session;
                    obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value)=movedown_session;
                    
                    obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.(obj.info.event.current_session).info.measurement_str;
                    
                    
                    obj.pmd.lb_measures.listbox.Value=obj.pmd.lb_measures.listbox.Value-1;
                    moveup_session=[];
                    movedown_session=[];
                    obj.cb_measure_listbox
                else
                    return
                end
            end
            
            
        end
        function cb_pmd_lb_measures_movedown(obj)
            if(numel(obj.pmd.lb_measures.listbox.String)==0 || obj.pmd.lb_measures.listbox.Value==0)
                return
            else
                if(numel(obj.pmd.lb_measures.listbox.String)>1 && obj.pmd.lb_measures.listbox.Value<obj.data.(obj.info.event.current_session).info.measurement_no)
                    moveup_session=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value+1);
                    movedown_session=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value);
                    obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value)=moveup_session;
                    obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(obj.pmd.lb_measures.listbox.Value+1)=movedown_session;
                    obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
                    
                    
                    moveup_session=obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value+1);
                    movedown_session=obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value);
                    obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value)=moveup_session;
                    obj.data.(obj.info.event.current_session).info.measurement_str(obj.pmd.lb_measures.listbox.Value+1)=movedown_session;
                    
                    obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.(obj.info.event.current_session).info.measurement_str;
                    
                    
                    obj.pmd.lb_measures.listbox.Value=obj.pmd.lb_measures.listbox.Value+1;
                    moveup_session=[];
                    movedown_session=[];
                    obj.cb_measure_listbox
                else
                    return
                end
            end
        end
        function cb_pmd_sub_code_editfield(obj)
            if(isvarname(obj.pmd.sub_code.editfield.String)==0)
                errordlg('Subject is an invalid string. Characters found in your string are not allowed by your operating system as filename. Please use a meaningful string that is not starting with a numeric character or space charachet and do not contain any special characters to proceed.','BEST Toolbox');
                obj.pmd.sub_code.editfield.String=[];
                return
            end
        end
        function cb_pmd_lb_measure_menu_loadresult(obj)
            if ~isfield(obj.bst.sessions,obj.info.event.current_session) || numel(obj.pmd.lb_measures.listbox.String)==0 %only sessions tree is added, add tree of measure here as well
                errordlg('No results exist for this measurement, Please collect the data if you wish to see the results for this particular measure.','BEST Toolbox');
                return
            end
            obj.fig.main.Widths([1 2 3])=[-1.15 -0 -3.35];
            obj.bst.factorizeConditions
            obj.resultsPanel;
            obj.bst.inputs.Figures=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Figures;
            for i=1:obj.pr.axesno
                ax=['ax' num2str(i)];
                Parent=obj.pr.ax.(ax).Parent;
                UIContextMenu=obj.pr.ax.(ax).UIContextMenu;
                delete(allchild(Parent))
                Figure=copy(obj.bst.inputs.Figures{i});
                
                Figure.Parent=Parent;
                Figure.UIContextMenu=UIContextMenu;
                obj.pr.ax.(ax)=Figure;
                
            end
            
            %% better would be to save all the app.pr parameters in object too so that entire information is intact, when results is called those may be assigned from the obj.inputs
            %% load all from particualr session and measure into inputs
            %% call results
            %% try copying in legacy mode so that all the necessary callbacks are copied too
            %% reasign Parent --DONE!
            
            
            
            %copy figures from
            % clear inputs ,
            % load Figures result from this particular measure and session into inputs
            
            %             obj.bst.inputs.rawData=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).RawData;
            %             obj.bst.inputs.results=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Results;
            %             obj.bst.inputs.trial=1;
            %             for tt=1:obj.bst.inputs.totalTrials
            %                 obj.bst.plotTrial;
            %                 obj.bst.inputs.trial=obj.bst.inputs.trial+1;
            %             end
            
            %% Old Code
            %             if(numel(obj.pmd.lb_measures.listbox.String)==0)
            %                 return
            %             else
            %                 if(strcmp(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable,'off'))
            %                     delete(obj.pr.mep.axes1)
            %                     delete(obj.pr.hotspot.axes1)
            %                     delete(obj.pr.mt.axes_mep)
            %                     delete(obj.pr.mt.axes_mtplot)
            %                     delete(obj.pr.ioc.axes_mep)
            %                     delete(obj.pr.ioc.axes_scatplot)
            %                     delete(obj.pr.ioc.axes_fitplot)
            %                     switch obj.info.event.current_measure
            %                         case 'MEP Measurement'
            %                             obj.pr_mep;
            %                             obj.bst.inputs.current_session=obj.info.event.current_session;
            %                             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %                             obj.bst.best_mep_posthoc();
            %                         case 'MEP Hotspot Search'
            %                             obj.pr_hotspot
            %                             obj.bst.inputs.current_session=obj.info.event.current_session;
            %                             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %                             obj.bst.best_hotspot_posthoc();
            %                         case 'MEP Motor Threshold Hunting'
            %                             obj.pr_mt
            %                             obj.bst.inputs.current_session=obj.info.event.current_session;
            %                             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %                             obj.bst.best_mt_posthoc();
            %                         case 'MEP Dose Response Curve_sp'
            %                             obj.pr_ioc
            %                             obj.bst.inputs.current_session=obj.info.event.current_session;
            %                             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %                             obj.bst.best_ioc_posthoc();
            %                     end
            %                 else
            %                     errordlg('No results exist for this measurement, Please collect the data if you wish to see the results for this particular measure.','BEST Toolbox');
            %                     return
            %                 end
            %             end
        end
        %% Protocol Designer or input panels
        function create_inputs_panel(obj)
            obj.pi.empty_panel = uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            obj.pi.no_measure_slctd_panel.handle=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Protocol Designer','FontWeight','Bold','TitlePosition','centertop' );
            obj.pi.no_measure_slctd_panel.vbox = uix.VBox( 'Parent', obj.pi.no_measure_slctd_panel.handle, 'Spacing', 5, 'Padding', 5  );
            uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox)
            uicontrol( 'Parent', obj.pi.no_measure_slctd_panel.vbox,'Style','text','String','No Protocol is selected','FontSize',11,'HorizontalAlignment','center','Units','normalized' );
            uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox);
            %           obj.panel.st=set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
            set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
        end
        %% Results Panel
        function resultsPanel(obj)
            total_axesno=obj.pr.axesno;
            Title=['Results - ' obj.bst.inputs.Protocol];
            obj.pr.panel_1= uix.Panel( 'Parent', obj.fig.pr_empty_panel, 'Padding', 5 ,'Units','normalized','Title', Title,'FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.pr.grid=uiextras.GridFlex('Parent',obj.pr.panel_1, 'Spacing', 4 );
            
            for i=1:total_axesno
                obj.pr.axesno=i;
                switch char(obj.pr.ax_measures{1,i})
                    case 'MEP_Measurement'
                        obj.pr_mep;
                    case 'MEP Scatter Plot'
                        obj.pr_scat_plot;
                    case 'MEP IOC Fit'
                        obj.pr_fit_plot;
                    case 'Motor Threshold Hunting'
                        obj.pr_MotorThresholdHunting;
                    case 'PhaseHistogram'
                        obj.pr_PhaseHistogram;
                    case 'TriggerLockedEEG'
                        obj.pr_TriggerLockedEEG
                    case 'RunningAmplitude'
                        obj.pr_RunningAmplitude;
                    case 'AmplitudeDistribution'
                        obj.pr_AmplitudeDistribution;
                    case 'Sensory Threshold Hunting'
                        obj.pr_PsychometricThresholdHunting;
                    case 'rsEEGMeasurement'
                        obj.pr_rsEEGMeasurement;
                    case 'StatusTable'
                        obj.pr_StatusTable;
                    case 'TEP Measurement'
                        %                             obj.pr_TEPMeasurement;
                        obj.pr_TriggerLockedEEG
                        
                end
            end
            switch obj.pr.axesno
                case 1
                    obj.pr.grid.ColumnSizes=-1;
                case 2
                    obj.pr.grid.ColumnSizes=[-1 -1];
                case 3
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                case 4
                    obj.pr.grid.RowSizes=[-1 -1];
                    obj.pr.grid.ColumnSizes=[-1 -1];
                case 5
                    uiextras.HBox( 'Parent', obj.pr.grid)
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 6
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 7
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 8
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 9
                    %                     uiextras.HBox( 'Parent', obj.pr.grid), uiextras.HBox( 'Parent', obj.pr.grid), uiextras.HBox( 'Parent', obj.pr.grid)
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1];
                case 10
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1];
                case 11
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1];
                case 12
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1];
                case 13
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1 -1];
                case 14
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1 -1];
                case 15
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1-1 -1];
                case 16
                    obj.pr.grid.ColumnSizes=[-1 -1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1 -1 -1];
            end
        end
        function create_results_panel(obj)
            obj.fig.pr_empty_panel= uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            
            %             obj.pr.empty_panel= uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            uix.Panel( 'Parent', obj.fig.pr_empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            %             set( obj.fig.main, 'Widths', [-1.15 -1.35 -2] );
        end
        
        
        
        function pr_mep(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','reset Mean MEP Plot','Callback',@obj.pr_ResetMEPMeanPlot,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Y-axis limits','Callback',@obj.pr_SetYAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set X-axis limits','Callback',@obj.pr_SetXAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y auto-fit','Callback',@obj.pr_AutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','X auto-fit','Callback',@obj.pr_XAutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','reset Mean MEP Amplitude status','Callback',@obj.pr_ResetMEPMeanAmp,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','set trials for Mean MEP Amplitude calculation','Callback',@obj.pr_setMEPMeanTrials,'Tag',obj.pr.ax_no);
            AxesTitle=['MEP Measurement ' obj.pr.ax_ChannelLabels{1,obj.pr.axesno}];
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 0 ,'Units','normalized','Title', AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes(uicontainer( 'Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            text(obj.pr.ax.(obj.pr.ax_no),1,1,'YLim-','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.1,1,'YLim+','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.7,1,'XLim-','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_XLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.4,1,'XLim+','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_XLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            obj.pr.ax.(obj.pr.ax_no).UserData.Colors=[1 0 0;0 1 0;0 0 1;0 1 1;1 0 1;0.7529 0.7529 0.7529;0.5020 0.5020 0.5020;0.4706 0 0;0.5020 0.5020 0;0 0.5020 0;0.5020 0 0.5020;0 0.5020 0.5020;0 0 0.5020;1 0.4980 0.3137;
                1 0 0;0 1 0;0 0 1;0 1 1;1 0 1;0.7529 0.7529 0.7529;0.5020 0.5020 0.5020;0.4706 0 0;0.5020 0.5020 0;0 0.5020 0;0.5020 0 0.5020;0 0.5020 0.5020;0 0 0.5020;1 0.4980 0.3137;
                1 0 0;0 1 0;0 0 1;0 1 1;1 0 1;0.7529 0.7529 0.7529;0.5020 0.5020 0.5020;0.4706 0 0;0.5020 0.5020 0;0 0.5020 0;0.5020 0 0.5020;0 0.5020 0.5020;0 0 0.5020;1 0.4980 0.3137;
                1 0 0;0 1 0;0 0 1;0 1 1;1 0 1;0.7529 0.7529 0.7529;0.5020 0.5020 0.5020;0.4706 0 0;0.5020 0.5020 0;0 0.5020 0;0.5020 0 0.5020;0 0.5020 0.5020;0 0 0.5020;1 0.4980 0.3137];
            obj.pr.ax.(obj.pr.ax_no).UserData.ColorsIndex=0;
            
        end
        function pr_YLimZoomIn(obj,source,~)
            
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            current_ylimMax=obj.pr.ax.(selectedAxes).YLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylimMin*0.50; %50 percent normalized decrement
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylimMax*0.50; %50 prcent normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),(mat4));
            ytickformat('%.2f');
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_YLimZoomOut(obj,source,~)
            
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            current_ylimMax=obj.pr.ax.(selectedAxes).YLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylimMin*1.50; %15 percent normalized decrement
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylimMax*1.50; %15% normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),(mat4));
            ytickformat('%.2f');
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_XLimZoomIn(obj,source,~)
            
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            current_ylimMax=obj.pr.ax.(selectedAxes).XLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).XLim(1);
            obj.pr.ax.(selectedAxes).XLim(1)=current_ylimMin*0.50; %50 percent normalized decrement
            obj.pr.ax.(selectedAxes).XLim(2)=current_ylimMax*0.50; %50 prcent normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
            mat4=unique(sort([0 mat3 mat2]));
            xticks(obj.pr.ax.(selectedAxes),(mat4));
            xtickformat('%.0f');
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.bst.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--','Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            obj.bst.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            uistack(obj.bst.info.handle_gridxy_mt_lines,'top');
            drawnow;
        end
        function pr_XLimZoomOut(obj,source,~)
            
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            current_ylimMax=obj.pr.ax.(selectedAxes).XLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).XLim(1);
            obj.pr.ax.(selectedAxes).XLim(1)=current_ylimMin*1.50; %15 percent normalized decrement
            obj.pr.ax.(selectedAxes).XLim(2)=current_ylimMax*1.50; %15% normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
            mat4=unique(sort([0 mat3 mat2]));
            xticks(obj.pr.ax.(selectedAxes),(mat4));
            xtickformat('%.0f');
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.bst.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--','Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            obj.bst.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            uistack(obj.bst.info.handle_gridxy_mt_lines,'top');
            drawnow;
        end
        function pr_AutoFit(obj,source,~)
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            obj.pr.ax.(selectedAxes).YLim=[-Inf Inf];
            yticks('auto');
            obj.pr.ax.(selectedAxes).YLim=[min(yticks(obj.pr.ax.(selectedAxes))) max(yticks(obj.pr.ax.(selectedAxes)))];
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_XAutoFit(obj,source,~)
            selectedAxes=source.Tag;
            if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
            obj.pr.ax.(selectedAxes).XLim=[obj.bst.inputs.prestim_scope_plt*(-1) obj.bst.inputs.poststim_scope_plt];
            mat1=linspace(obj.bst.inputs.prestim_scope_plt*(-1),obj.bst.inputs.poststim_scope_plt,10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.poststim_scope_plt];
            mat=unique(sort([mat1 mat2]));
            xticks(mat);
            xtickformat('%.0f');
            obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
            obj.bst.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--','Parent',obj.pr.ax.(selectedAxes)) ;
            obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            obj.bst.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
            uistack(obj.bst.info.handle_gridxy_mt_lines,'top');
            drawnow;
        end
        function pr_FontSize(obj,source,~)
            selectedAxes=source.Tag;
            f=figure('Name','Font Size | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .15 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter Font Size:','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            font=uicontrol( 'Style','edit','Parent', f,'String','11','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.4 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Set Size','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setFontSize);
            function setFontSize(~,~)
                try
                    obj.pr.ax.(selectedAxes).FontSize=str2double(font.String);
                    obj.pr.ax.(selectedAxes).UserData.status.FontSize=str2double(font.String);
                    drawnow;
                    close(f)
                catch
                    close(f)
                end
            end
        end
        function pr_SetYAxisLimits(obj,source,~)
            %Rule: Limits input syntax [LowLimit HighLimit]
            selectedAxes=source.Tag;
            f=figure('Name','Y Axis Limits | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .35 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter Y Axis Limits [min max](microV):','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            limmin=uicontrol( 'Style','edit','Parent', f,'String','-50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.2 0.4]);
            limmax=uicontrol( 'Style','edit','Parent', f,'String','50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.75 0.5 0.2 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Set','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setLimits);
            function setLimits(~,~)
                try
                    if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
                    obj.pr.ax.(selectedAxes).YLim=[str2double(limmin.String) str2double(limmax.String)];
                    close(f);
                    mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
                    mat4=unique(sort([0 mat3]));
                    yticks(obj.pr.ax.(selectedAxes),(mat4));
                    ytickformat('%.2f');
                    obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
                    obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    drawnow;
                catch
                    close(f)
                end
            end
        end
        function pr_SetXAxisLimits(obj,source,~)
            %Rule: Limits input syntax [LowLimit HighLimit]
            selectedAxes=source.Tag;
            f=figure('Name','X Axis Limits | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .35 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter X Axis Limits [min max](ms):','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            limmin=uicontrol( 'Style','edit','Parent', f,'String','-50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.2 0.4]);
            limmax=uicontrol( 'Style','edit','Parent', f,'String','50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.75 0.5 0.2 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Set','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setLimits);
            function setLimits(~,~)
                try
                    if isfield(obj.pr.ax.(selectedAxes).UserData,'GridLines'), delete(obj.pr.ax.(selectedAxes).UserData.GridLines), end
                    obj.pr.ax.(selectedAxes).XLim=[str2double(limmin.String) str2double(limmax.String)];
                    close(f);
                    mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
                    mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
                    mat4=unique(sort([0 mat3 mat2]));
                    xticks(obj.pr.ax.(selectedAxes),(mat4));
                    xtickformat('%.0f');
                    obj.pr.ax.(selectedAxes).UserData.GridLines=gridxy([0 (obj.bst.inputs.mep_onset):0.25:(obj.bst.inputs.mep_offset)],'Color',[219/255 246/255 255/255],'linewidth',4,'Parent',obj.pr.ax.(selectedAxes)) ;
                    obj.bst.info.handle_gridxy_mt_lines=gridxy([],[-0.05*1000 0.05*1000],'Color',[0.45 0.45 0.45],'linewidth',1,'LineStyle','--','Parent',obj.pr.ax.(selectedAxes)) ;
                    obj.pr.ax.(selectedAxes).UserData.GridLines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    obj.bst.info.handle_gridxy_mt_lines.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    uistack(obj.bst.info.handle_gridxy_mt_lines,'top');
                    drawnow;
                catch
                    close(f)
                end
            end
        end
        function pr_ResetMEPMeanPlot(obj,source,~)
            try
                if(obj.bst.inputs.trial>2)
                    obj.bst.info.plt.(source.Tag).mean.UserData.TrialNoForMean=obj.bst.inputs.trial;
                end
            catch
                disp('BEST Toolbox: Calling Reset function in this case have no effect because the data does not exist in this file for this result');
            end
        end
        function pr_FigureExport(obj,source,~)
            try
                FigureFileName1=erase(obj.bst.info.matfilstr,'.mat');
            catch
                date=datestr(now); date(date == ' ') = '_'; date(date == '-') = '_'; date(date == ':') = '_';
                exp_name=obj.pmd.exp_title.editfield.String; exp_name(exp_name == ' ') = '_';
                subj_code=obj.pmd.sub_code.editfield.String; subj_code(subj_code == ' ') = '_';
                save_str=[exp_name '_' subj_code];
                FigureFileName1=['BEST_' date '_' save_str];
            end
            iaxes=str2double(erase(source.Tag,'ax'));
            if isfield(obj.pr,'ax_ChannelLabels_0')
                FigureFileName=[FigureFileName1 '_' obj.pr.ax_measures{1,iaxes} '_' obj.pr.ax_ChannelLabels_0{1,iaxes} '_' obj.pr.ax_ChannelLabels{1,iaxes}];
            else
                FigureFileName=[FigureFileName1 '_' obj.pr.ax_measures{1,iaxes} '_' obj.pr.ax_ChannelLabels{1,iaxes}];
            end
            ax=['ax' num2str(iaxes)];
            Figure=figure('Name',FigureFileName,'NumberTitle','off');
            copyobj(obj.pr.ax.(ax),Figure)
            set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
        end
        function pr_ResetMEPMeanAmp(obj,source,~)
        end
        function pr_setMEPMeanTrials(obj,source,~)
        end
        function pr_NoOfTrialsToAverage(obj,source,~)
            Channel=source.Tag;
            ax=source.UserData;
            f=figure('Name','Set Trials to Avg | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .15 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter No of Last Trials to Avg for Threshold:','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            NoOfTrialsToAverage=uicontrol( 'Style','edit','Parent', f,'String','10','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.4 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Update','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@set);
            function set(~,~)
                try
                    obj.bst.inputs.results.(Channel).NoOfLastTrialsToAverage=str2double(NoOfTrialsToAverage.String);
                    obj.bst.computeMotorThreshold(Channel,obj.bst.inputs.Handles.(ax).mtplot.YData)
                    obj.pr.ax.(ax).UserData.status.String={['Trials to Average:' num2str(obj.bst.inputs.results.(Channel).NoOfLastTrialsToAverage)],['Threshold (%MSO):' num2str(obj.bst.inputs.results.(Channel).MotorThreshold)]};
                    close(f)
                catch
                    close(f)
                end
            end
        end
        function pr_OverWirtePeakFrequency(obj,source,~)
            Channel=source.Tag;
            ax=source.UserData;
            f=figure('Name','Overwrite Peak Frequency | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .15 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter Peak Frequency you want to set for this Channel:','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            PeakFrequency=uicontrol( 'Style','edit','Parent', f,'String','10','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.4 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Update','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@set);
            function set(~,~)
                try
                    obj.bst.inputs.results.PeakFrequency.(Channel)=str2double(PeakFrequency.String);
                    obj.pr.ax.(ax).UserData.TextAnnotationPeakFrequency.String={['Peak Frequency (Hz):' num2str(obj.bst.inputs.results.PeakFrequency.(Channel))]};
                    close(f)
                catch
                    close(f)
                end
            end
        end
        function pr_EEGYLimZoomIn(obj,source,~)
            selectedAxes=source.Tag;
            current_ylimMax=obj.pr.ax.(selectedAxes).YLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylimMin*0.50; %50 percent normalized decrement
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylimMax*0.50; %50 prcent normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),(mat4));
            ytickformat('%.2f');
            delete(findobj('Tag','TriggerLockedEEGZeroLine'))
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_EEGYLimZoomOut(obj,source,~)
            selectedAxes=source.Tag;
            current_ylimMax=obj.pr.ax.(selectedAxes).YLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylimMin*1.50; %15 percent normalized decrement
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylimMax*1.50; %15% normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),(mat4));
            ytickformat('%.2f');
            delete(findobj('Tag','TriggerLockedEEGZeroLine'))
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_EEGXLimZoomIn(obj,source,~)
            selectedAxes=source.Tag;
            current_ylimMax=obj.pr.ax.(selectedAxes).XLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).XLim(1);
            obj.pr.ax.(selectedAxes).XLim(1)=current_ylimMin*0.50; %50 percent normalized decrement
            obj.pr.ax.(selectedAxes).XLim(2)=current_ylimMax*0.50; %50 prcent normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
            mat4=unique(sort([0 mat3 mat2]));
            xticks(obj.pr.ax.(selectedAxes),(mat4));
            xtickformat('%.0f');
            delete(findobj('Tag','TriggerLockedEEGZeroLine'))
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_EEGXLimZoomOut(obj,source,~)
            selectedAxes=source.Tag;
            current_ylimMax=obj.pr.ax.(selectedAxes).XLim(2);
            current_ylimMin=obj.pr.ax.(selectedAxes).XLim(1);
            obj.pr.ax.(selectedAxes).XLim(1)=current_ylimMin*1.50; %15 percent normalized decrement
            obj.pr.ax.(selectedAxes).XLim(2)=current_ylimMax*1.50; %15% normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
            mat4=unique(sort([0 mat3 mat2]));
            xticks(obj.pr.ax.(selectedAxes),(mat4));
            xtickformat('%.0f');
            delete(findobj('Tag','TriggerLockedEEGZeroLine'))
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_EEGYAutoFit(obj,source,~)
            selectedAxes=source.Tag;
            obj.pr.ax.(selectedAxes).YLim=[-Inf Inf];
            yticks('auto');
            obj.pr.ax.(selectedAxes).YLim=[min(yticks(obj.pr.ax.(selectedAxes))) max(yticks(obj.pr.ax.(selectedAxes)))];
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes));hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_EEGXAutoFit(obj,source,~)
            selectedAxes=source.Tag;
            obj.pr.ax.(selectedAxes).XLim=[obj.bst.inputs.prestim_scope_plt*(-1) obj.bst.inputs.poststim_scope_plt];
            mat1=linspace(obj.bst.inputs.prestim_scope_plt*(-1),obj.bst.inputs.poststim_scope_plt,10);
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.poststim_scope_plt];
            mat=unique(sort([mat1 mat2]));
            xticks(mat);
            xtickformat('%.0f');
            delete(findobj('Tag','TriggerLockedEEGZeroLine'))
            ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
            drawnow;
        end
        function pr_SetEEGYAxisLimits(obj,source,~)
            %Rule: Limits input syntax [LowLimit HighLimit]
            selectedAxes=source.Tag;
            f=figure('Name','Y Axis Limits | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .35 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter Y Axis Limits [min max](microV):','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            limmin=uicontrol( 'Style','edit','Parent', f,'String','-50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.2 0.4]);
            limmax=uicontrol( 'Style','edit','Parent', f,'String','50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.75 0.5 0.2 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Set','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setLimits);
            function setLimits(~,~)
                try
                    obj.pr.ax.(selectedAxes).YLim=[str2double(limmin.String) str2double(limmax.String)];
                    close(f);
                    mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),10);
                    mat4=unique(sort([0 mat3]));
                    yticks(obj.pr.ax.(selectedAxes),(mat4));
                    ytickformat('%.2f');
                    delete(findobj('Tag','TriggerLockedEEGZeroLine'))
                    ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    drawnow;
                catch
                    close(f)
                end
            end
        end
        function pr_SetEEGXAxisLimits(obj,source,~)
            %Rule: Limits input syntax [LowLimit HighLimit]
            selectedAxes=source.Tag;
            f=figure('Name','X Axis Limits | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .35 .05]);
            uicontrol( 'Style','text','Parent', f,'String','Enter X Axis Limits [min max](ms):','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
            limmin=uicontrol( 'Style','edit','Parent', f,'String','-50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.2 0.4]);
            limmax=uicontrol( 'Style','edit','Parent', f,'String','50','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.75 0.5 0.2 0.4]);
            uicontrol( 'Style','pushbutton','Parent', f,'String','Set','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setLimits);
            function setLimits(~,~)
                try
                    obj.pr.ax.(selectedAxes).XLim=[str2double(limmin.String) str2double(limmax.String)];
                    close(f);
                    mat3=linspace(obj.pr.ax.(selectedAxes).XLim(1),obj.pr.ax.(selectedAxes).XLim(2),10);
                    mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.inputs.EMGXLimit(2)];
                    mat4=unique(sort([0 mat3 mat2]));
                    xticks(obj.pr.ax.(selectedAxes),(mat4));
                    xtickformat('%.0f');
                    delete(findobj('Tag','TriggerLockedEEGZeroLine'))
                    ZeroLine=gridxy(0,'Color','k','linewidth',2,'Parent',obj.pr.ax.(selectedAxes),'Tag','TriggerLockedEEGZeroLine');hold on; ZeroLine.Annotation.LegendInformation.IconDisplayStyle = 'off';
                    drawnow;
                catch
                    close(f)
                end
            end
        end
        function pr_scat_plot(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'MEP Scatter Plot','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer( 'Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
        end
        function pr_fit_plot(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            AxesTitle=['MEP Dose-Response Curve ' obj.pr.ax_ChannelLabels{1,obj.pr.axesno}];
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer('Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
        end
        function pr_threshold_trace_plot(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            obj.pr.ax_no
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','Y-axis Max limit Increase','Callback',@obj.ymaxInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Max limit Decrease','Callback',@obj.ymaxDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Increase','Callback',@obj.yminInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Decrease','Callback',@obj.yminDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Insert Y-axis limits mannualy','Callback',@obj.ylims,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Change Font Size','Callback',@(~,~)obj.fontSize,'Tag',obj.pr.ax_no);
            
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'Threshold Intensity Trace','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.clab.(obj.pr.ax_no), 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.current_mep_label.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_mep.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep_label.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.ax.(obj.pr.ax_no)=axes( 'Parent',  mep1_r2,'Units','normalized','uicontextmenu',ui_menu);
            
            
            
            set(mep1_vb,'Heights',[30 -10])
            
            
        end
        function ymaxInc(obj,source,~)
            selectedAxes=source.Tag;
            current_ylim=obj.pr.ax.(selectedAxes).YLim(2);
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylim*1.1; %10% normalized measure
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),5);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),mat4);
        end
        function ymaxDec(obj,source,~)
            selectedAxes=source.Tag;
            current_ylim=obj.pr.ax.(selectedAxes).YLim(2);
            obj.pr.ax.(selectedAxes).YLim(2)=current_ylim*0.9;
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),5);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),mat4);
        end
        function yminInc(obj,source,~)
            selectedAxes=source.Tag;
            current_ylim=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylim*1.1;
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),5);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),mat4);
        end
        function yminDec(obj,source,~)
            selectedAxes=source.Tag;
            current_ylim=obj.pr.ax.(selectedAxes).YLim(1);
            obj.pr.ax.(selectedAxes).YLim(1)=current_ylim*0.9;
            mat3=linspace(obj.pr.ax.(selectedAxes).YLim(1),obj.pr.ax.(selectedAxes).YLim(2),5);
            mat4=unique(sort([0 mat3]));
            yticks(obj.pr.ax.(selectedAxes),mat4);
        end
        function ylims(obj,source,~)
            selectedAxes=source.Tag;
            prompt = {'Y-axis mininium limit(micro Volts):','Y-axis maximum limit (micro Volts):'};
            dlgtitle = 'Insert Y-axis limits Manualy';
            dims = [1 40];
            definput = {num2str(obj.pr.ax.(selectedAxes).YLim(1)),num2str(obj.pr.ax.(selectedAxes).YLim(2))};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            obj.pr.ax.(selectedAxes).YLim=[str2double(answer{1,1}),str2double(answer{2,1})];
        end
        
        function pr_threshold(obj)
            obj.pr.clab.(obj.pr.axesno)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'MEP Threshold Hunting','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.clab.(obj.pr.axesno), 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.current_mep_label.(obj.pr.axesno)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_mep.(obj.pr.axesno)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep_label.(obj.pr.axesno)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep.(obj.pr.axesno)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.ax.(obj.pr.axesno)=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
        end
        function pr_ioc_NEW(obj)
            obj.pr.clab.(obj.pr.axesno)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'MEP IOC','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.clab.(obj.pr.axesno), 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.current_mep_label.(obj.pr.axesno)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_mep.(obj.pr.axesno)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep_label.(obj.pr.axesno)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mean_mep.(obj.pr.axesno)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.ax.(obj.pr.axesno)=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
        end
        function pr_PhaseHistogram(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'Phase Histogram','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=polaraxes( uicontainer('Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
        end
        
        function pr_TriggerLockedEEG(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Y-axis limits','Callback',@obj.pr_SetEEGYAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set X-axis limits','Callback',@obj.pr_SetEEGXAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y auto-fit','Callback',@obj.pr_EEGYAutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','X auto-fit','Callback',@obj.pr_EEGXAutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'Trigger Locked EEG','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer('Parent',   obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            xlabel('Time (ms)'); ylabel('EEG Potential (\mu V)');
            text(obj.pr.ax.(obj.pr.ax_no),1,1,'YLim-','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_EEGYLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.1,1,'YLim+','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_EEGYLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.7,1,'XLim-','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_EEGXLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.4,1,'XLim+','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_EEGXLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
        end
        function pr_RunningAmplitude(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','reset Mean MEP Plot','Callback',@obj.pr_ResetMEPMeanPlot,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Y-axis limits','Callback',@obj.pr_SetYAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','auto-fit','Callback',@obj.pr_AutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','reset Mean MEP Amplitude status','Callback',@obj.pr_ResetMEPMeanAmp,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','set trials for Mean MEP Amplitude calculation','Callback',@obj.pr_setMEPMeanTrials,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 0 ,'Units','normalized','Title', 'Oscillation Amplitude','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes(uicontainer( 'Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            xlabel(['Data for Past ' num2str(obj.bst.inputs.AmplitudeAssignmentPeriod) ' mins']);
            ylabel('EEG Quantile Amplitude (\mu V)');
            xticks([]); xticklabels([]);
            %             obj.pr.ax.(obj.pr.ax_no).xtick=[]; obj.pr.ax.(obj.pr.ax_no).xticklabel=[];
            text(obj.pr.ax.(obj.pr.ax_no),1,1,'zoomin','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.1,1,'   zoomout','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
        end
        function pr_AmplitudeDistribution(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','reset Mean MEP Plot','Callback',@obj.pr_ResetMEPMeanPlot,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Y-axis limits','Callback',@obj.pr_SetYAxisLimits,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','auto-fit','Callback',@obj.pr_AutoFit,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','reset Mean MEP Amplitude status','Callback',@obj.pr_ResetMEPMeanAmp,'Tag',obj.pr.ax_no);
            % %             uimenu(ui_menu,'label','set trials for Mean MEP Amplitude calculation','Callback',@obj.pr_setMEPMeanTrials,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 0 ,'Units','normalized','Title', 'Amplitude Distribution','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes(uicontainer( 'Parent',  obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            ylabel('Amplitude (microV)');
            xticks([]); xticklabels([]);
            text(obj.pr.ax.(obj.pr.ax_no),1,1,'zoomin','units','normalized','HorizontalAlignment','right','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomIn,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
            text(obj.pr.ax.(obj.pr.ax_no),0.1,1,'   zoomout','units','normalized','HorizontalAlignment','left','VerticalAlignment','bottom','ButtonDownFcn',@obj.pr_YLimZoomOut,'Tag',obj.pr.ax_no,'color',[0.55 0.55 0.55]);
        end
        function pr_MotorThresholdHunting(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Last No. of Trials to Calculate Average for Threshold','Callback',@obj.pr_NoOfTrialsToAverage,'Tag',obj.pr.ax_ChannelLabels{obj.pr.axesno},'UserData',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            AxesTitle=['Threshold Trace - ' obj.pr.ax_ChannelLabels{1,obj.pr.axesno}];
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title',AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer('Parent',   obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            xlabel('Trial Number'), ylabel('Stimulation Intensity (mA)');
        end
        function pr_PsychometricThresholdHunting(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Last No. of Trials to Calculate Average for Threshold','Callback',@obj.pr_NoOfTrialsToAverage,'Tag',obj.pr.ax_ChannelLabels{obj.pr.axesno});
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            AxesTitle=['Threshold Trace - ' obj.pr.ax_ChannelLabels{1,obj.pr.axesno}];
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title',AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer('Parent',   obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            xlabel('Trial Number'), ylabel('Stimulation Intensity (mA)');
        end
        function pr_rsEEGMeasurement(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            AxesTitle=[ obj.pr.ax_ChannelLabels_0{obj.pr.axesno} obj.pr.ax_ChannelLabels{obj.pr.axesno}];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','Overwrite Peak Frequency of this Channel','Callback',@obj.pr_OverWirtePeakFrequency,'Tag',obj.pr.ax_ChannelLabels{obj.pr.axesno},'UserData',obj.pr.ax_no);
            uimenu(ui_menu,'label','set Font size','Callback',@obj.pr_FontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title',AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ax.(obj.pr.ax_no)=axes( uicontainer('Parent',   obj.pr.clab.(obj.pr.ax_no)),'Units','normalized','uicontextmenu',ui_menu);
            %             obj.pr.ax.(obj.pr.ax_no).UserData.TextAnnotationPeakFrequency Future Release: take the text annnotations out of those graphs since they will be needed in results reloading
            xlabel('Frequency (Hz)'), ylabel('Power');
        end
        function pr_StatusTable(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Font size','Callback',@cbFontSize,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title','Protocol Progress','FontWeight','bold','FontSize',12,'TitlePosition','centertop','uicontextmenu',ui_menu );
            obj.pr.ax.(obj.pr.ax_no)=uitable(uicontainer( 'Parent', obj.pr.clab.(obj.pr.ax_no)),'uicontextmenu',ui_menu);
            obj.pr.ax.(obj.pr.ax_no).Data={'','';'','';'',''};
            obj.pr.ax.(obj.pr.ax_no).FontSize=12;
            obj.pr.ax.(obj.pr.ax_no).ColumnName = {'Current Trial','Next Trial'};
            obj.pr.ax.(obj.pr.ax_no).ColumnWidth = {100,100};
            obj.pr.ax.(obj.pr.ax_no).RowName = {'Trials','ITI (ms)','TS',};
            obj.pr.ax.(obj.pr.ax_no).RowStriping='on';
            obj.pr.ax.(obj.pr.ax_no).Units='normalized'; %Future Use: obj.pr.ax.(obj.pr.ax_no).Position(3:4) = obj.pr.ax.(obj.pr.ax_no).Extent(3:4);
            if obj.pr.axesno==2 || obj.pr.axesno==3
                obj.pr.ax.(obj.pr.ax_no).Position = [0.25 0.5 0.41 0.135];
                obj.pr.ax.(obj.pr.ax_no).Units='pixels';
                obj.pr.ax.(obj.pr.ax_no).Position(3:4) = obj.pr.ax.(obj.pr.ax_no).Extent(3:4);
            else
                %                 obj.pr.ax.(obj.pr.ax_no).Position = [0.15 0.5 0.65 0.215];
                obj.pr.ax.(obj.pr.ax_no).Units='pixels';
                obj.pr.ax.(obj.pr.ax_no).Position(3:4) = obj.pr.ax.(obj.pr.ax_no).Extent(3:4);
            end
            function cbFontSize(source,~)
                ax=source.Tag;
                f=figure('Name','Font Size | BEST Toolbox','numbertitle', 'off','ToolBar', 'none','MenuBar', 'none','WindowStyle', 'modal','Units', 'normal', 'Position', [0.5 0.5 .15 .05]);
                uicontrol( 'Style','text','Parent', f,'String','Enter Font Size:','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.05 0.5 0.5 0.4]);
                font=uicontrol( 'Style','edit','Parent', f,'String','11','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.5 0.5 0.4 0.4]);
                uicontrol( 'Style','pushbutton','Parent', f,'String','Set Size','FontSize',11,'HorizontalAlignment','center','Units','normalized','Position',[0.1 0.05 0.8 0.4],'Callback',@setFontSize);
                function setFontSize(~,~)
                    try
                        obj.pr.ax.(ax).FontSize=str2double(font.String);
                        close(f)
                    catch
                        close(f)
                    end
                end
            end
        end
        function pr_TEPMeasurement(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            AxesTitle=obj.pr.ax_ChannelLabels{obj.pr.axesno};
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','set Font size','Callback',@cbFontSize,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','export as MATLAB Figure','Callback',@obj.pr_FigureExport,'Tag',obj.pr.ax_no);
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title',AxesTitle,'FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.container.(obj.pr.ax_no)=uicontainer('Parent',   obj.pr.clab.(obj.pr.ax_no),'uicontextmenu',ui_menu);
            %             obj.pr.ax.(obj.pr.ax_no)=axes('Parent',   obj.pr.container.(obj.pr.ax_no),'Units','normalized','uicontextmenu',ui_menu);
        end
        %% MEP Hotspot Search Section
        function pi_hotspot(obj)
            obj.fig.main.Widths([1 2 3])=[-1.15 -3.35 -0];
            Panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','MEP Hotspot Search' ,'FontWeight','Bold','TitlePosition','centertop');
            vb = uix.VBox( 'Parent', Panel, 'Spacing', 5, 'Padding', 5  );
            
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            obj.pi.hotspot.InputDevice=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.hotspot.OutputDevice=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Tag','OutputDevice','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Trigger Mode:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.ProtocolMode=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',{'Automated','Manual'},'FontSize',11,'Tag','ProtocolMode','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.MEPSearchWindow=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Tag','MEPSearchWindow','callback',@cb_par_saving);
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Tag','EMGExtractionPeriod','callback',@cb_par_saving);
            set( mep_panel_row11, 'Widths', [150 -2]);
            
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.EMGXLimit=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Tag','EMGXLimit','callback',@cb_par_saving);
            set( mep_panel_row11, 'Widths', [150 -2]);
            
            mep_panel_row4 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No. of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.TrialsPerCondition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.ITI=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
            set( mep_panel_row5, 'Widths', [150 -2]);
            %
            uiextras.HBox( 'Parent', vb);
            
            
            set(vb,'Heights',[30 30 30 42 42 42 42 42 35 -1])
            Interactivity;
            function cb_run_hotspot
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolMode
                    case 1 %Automated
                        obj.bst.best_hotspot
                    case 2 %Manual
                        obj.bst.best_hotspot_manual
                end
            end
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'OutputDevice') || strcmp(source.Tag,'ProtocolMode')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                    if strcmp(source.Tag,'ProtocolMode')
                        switch source.Value
                            case 1 % Automated
                                mep_panel_row5.Visible='on';
                            case 2 % Manual
                                mep_panel_row5.Visible='off';
                        end
                    end
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            function Interactivity
                ParametersFieldNames=fieldnames(obj.pi.hotspot);
                for iLoadingParameters=1:numel(ParametersFieldNames)
                    obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                end
            end
        end
        function default_par_hotspot(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='100';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.OutputDevice=1;
            obj.info.defaults.ProtocolMode=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.MEPOnset='15';
            obj.info.defaults.MEPOffset='50';
            obj.info.defaults.MEPSearchWindow='15 50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EMGExtractionPeriod='-50 150';
            obj.info.defaults.EMGXLimit='-50 150';
            obj.info.defaults.EMGDisplayYLimMax={3000};
            obj.info.defaults.EMGDisplayYLimMin={-3000};
            obj.info.defaults.Protocol={'MEP Hotspot Search Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            si=NaN;
            for idefaults=1:numel(si)
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={'Select'};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults)};
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_hotspot_par(obj)
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    obj.pi.hotspot.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                end
            end
        end
        %% MEP Section
        function pi_mep(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Evoked Potentials (MEPs) Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mep.r0=uix.HBox( 'Parent', obj.pi.mep.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.mep.r0p1=uix.Panel( 'Parent', obj.pi.mep.r0 ,'Units','normalized');
            obj.pi.mep.r0v1 = uix.VBox( 'Parent', obj.pi.mep.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.mep.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.mep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.mep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            
            
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.mep.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.mep.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.mep.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_mep_conditions);%add condition
            obj.pi.mep.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_mep_stim); %add stimulator
            obj.pi.mep.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_mep_pulse); %add single pulse
            obj.pi.mep.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_mep_pulse);%add burst or train
            obj.pi.mep.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_mep_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            
            obj.pi.mep.r0v2 = uix.VBox( 'Parent', obj.pi.mep.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.mep.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            table = obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.mep.r0v2, 'Padding', 5 );
            obj.pi.mep.r0v2.Heights=[200 -1];
            set(obj.pi.mep.r0,'Widths',[-1.45 -3]);
            obj.pi.mep.cond.no=0;
            obj.cb_cm_Nconditions;
            Interactivity;
            cb_SetHeights;
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.mep.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.mep.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Montage:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.RealTimeChannelsMontage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsMontage','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.RealTimeChannelsWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        obj.pi.mep.ImportPeakFrequencyFromProtocols=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8z ,'String',{'Select'},'FontSize',11,'Tag','Bin','Callback',@set_PeakFrequency);
                        obj.pi.mep.ImportPeakFrequencyFromProtocols.String=getPeakFrequencyProtocols;
                        set( mep_panel_row8z, 'Widths', [150 -2 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.PhaseTolerance=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.mep.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -3 -1]);
                        
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period(minutes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( mep_panel_row2z, 'Widths', [150 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[30 35 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModvBox.Heights=[ 35 45 45 45 45];
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EEGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing',  0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EEGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1];%[35 42 42 42 42 42 42];
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.mep.r0v1,'Heights',[40 90 250 -1 55]);
                    case 2
                        set(obj.pi.mep.r0v1,'Heights',[-0.6 -9 -6 0 -1.1]);
                        set(obj.pi.mep.r0,'Widths',[-2 -3]);
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            function Interactivity
                ParametersFieldNames=fieldnames(obj.pi.mep);
                for iLoadingParameters=1:numel(ParametersFieldNames)
                    try
                        obj.pi.mep.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                    catch
                    end
                end
                table.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                obj.pi.mm.tab.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
            end
            function PeakFrequencyProtocols=getPeakFrequencyProtocols
                indexPeakFrequencyProtocols= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'rsEEG Measurement'));
                PeakFrequencyProtocols=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(indexPeakFrequencyProtocols);
                if isempty(PeakFrequencyProtocols)
                    PeakFrequencyProtocols={'Select'};
                end
            end
            function set_PeakFrequency(source,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                if ~strcmpi(source.String,'Select') % #TODO: what if the source.string is select , then ignore this overall action)
                    montages=numel(eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels));
                    if montages>1
                        for montage=1:montages
                            montagechannels=eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels);
                            AllMontages{montage}=erase(char(join(montagechannels{montage})),' ');
                        end
                        [indx,tf] = listdlg('PromptString',{'Multiple Montages were found in your selection','Select one Montage.',''},'SelectionMode','single','ListString',AllMontages);
                        if tf==1
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{indx};
                            ImportPeakFrequencyFromMontage=AllMontages{indx};
                        elseif tf==0
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{1};
                            ImportPeakFrequencyFromMontage=AllMontages{1};
                        end
                    else
                        ImportPeakFrequencyFromMontage=erase(char(join(obj.par.(obj.info.event.current_session).(ImportPeakFrequencyFromProtocol).MontageChannels{1})),' ');
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=ImportPeakFrequencyFromMontage;
                    end
                    try
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency=obj.bst.sessions.(obj.info.event.current_session).(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol).results.PeakFrequency.(ImportPeakFrequencyFromMontage);
                    catch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency='Not Found';
                    end
                    obj.pi.mep.PeakFrequency.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency;
                end
            end
            
        end
        function default_par_mep(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.RealTimeChannelsMontage=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.RealTimeChannelsWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='';
            obj.info.defaults.ImportPeakFrequencyFromProtocol='';
            obj.info.defaults.ImportPeakFrequencyFromMontage='';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.MEPOnset='15';
            obj.info.defaults.MEPOffset='50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.MEPSearchWindow='15 50';
            obj.info.defaults.EMGExtractionPeriod='-50 150';
            obj.info.defaults.EMGXLimit='-50 150';
            obj.info.defaults.EEGExtractionPeriod='-100 100';
            obj.info.defaults.EEGXLimit='-100 100';
            obj.info.defaults.EEGYLimit='-100 100';
            obj.info.defaults.EMGDisplayYLimMax={3000};
            obj.info.defaults.EMGDisplayYLimMin={-3000};
            obj.info.defaults.Protocol={'MEP Measurement Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            si=[30 40 50 60 70 80];
            for idefaults=1:6
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=50;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_mep_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.mep.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.mep.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% MEP DRC
        function pi_drc(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.drc.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','MEP Dose Response Curve' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.drc.r0=uix.HBox( 'Parent', obj.pi.drc.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.drc.r0p1=uix.Panel( 'Parent', obj.pi.drc.r0 ,'Units','normalized');
            obj.pi.drc.r0v1 = uix.VBox( 'Parent', obj.pi.drc.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.drc.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.drc.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.drc.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.drc.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.drc.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.drc.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_drc_conditions);%add condition
            obj.pi.drc.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_drc_stim); %add stimulator
            obj.pi.drc.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_drc_pulse); %add single pulse
            obj.pi.drc.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_drc_pulse);%add burst or train
            obj.pi.drc.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_drc_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            obj.pi.drc.r0v2 = uix.VBox( 'Parent', obj.pi.drc.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.drc.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.drc.r0v2, 'Padding', 5 );
            obj.pi.drc.r0v2.Heights=[200 -1];
            set(obj.pi.drc.r0,'Widths',[-2 -3]);
            obj.pi.drc.cond.no=0;
            obj.cb_cm_Nconditions;
            cb_SetHeights
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.drc.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.drc.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Montage:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.RealTimeChannelsMontage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsMontage','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.RealTimeChannelsWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        obj.pi.drc.ImportPeakFrequencyFromProtocols=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8z ,'String',{'Select'},'FontSize',11,'Tag','Bin','Callback',@set_PeakFrequency);
                        obj.pi.drc.ImportPeakFrequencyFromProtocols.String=getPeakFrequencyProtocols;
                        set( mep_panel_row8z, 'Widths', [150 -2 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.PhaseTolerance=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.drc.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -3 -1]);
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 0, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period(s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( mep_panel_row2z, 'Widths', [200 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1];%[30 35 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Target  Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGTargetChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGTargetChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Dose Function:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        DoseFunctionString={'Test Stimulus (TS)','Condtion Stimulus (CS)','Inter Stimulus Interval (ISI)'}; % ,'Inter Trial Interval (ITI)'} % 31-May-2020 20:14:09
                        obj.pi.drc.DoseFunction=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',DoseFunctionString,'Tag','DoseFunction','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','Response Function:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.ResponseFunctionNumerator=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','ResponseFunctionNumerator','callback',@cb_par_saving);
                        uicontrol( 'Style','text','Parent', expModr4,'String','?','FontSize',13,'HorizontalAlignment','center','Units','normalized');
                        obj.pi.drc.ResponseFunctionDenominator=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','ResponseFunctionDenominator','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 30 -2];
                        
                        expModvBox.Heights=[35 45 45 45 45 45 30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Target  Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGTargetChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGTargetChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EEGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.EEGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Dose Function:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        DoseFunctionString={'Test Stimulus (TS)','Condtion Stimulus (CS)','Inter Stimulus Interval (ISI)'}; % ,'Inter Trial Interval (ITI)'} % 31-May-2020 20:14:09
                        obj.pi.drc.DoseFunction=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',DoseFunctionString,'Tag','DoseFunction','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','Response Function:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.drc.ResponseFunctionNumerator=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','ResponseFunctionNumerator','callback',@cb_par_saving);
                        uicontrol( 'Style','text','Parent', expModr4,'String','?','FontSize',13,'HorizontalAlignment','center','Units','normalized');
                        obj.pi.drc.ResponseFunctionDenominator=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','ResponseFunctionDenominator','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 30 -2];
                        
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1];%[35 35 45 45 45 45 45 30 35];
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.drc.r0v1,'Heights',[40 90 370 -1 55])
                    case 2
                        set(obj.pi.drc.r0v1,'Heights',[-0.6 -9 -7 0 -1]);
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand') || strcmp(source.Tag,'DoseFunction')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
            end
            function PeakFrequencyProtocols=getPeakFrequencyProtocols
                indexPeakFrequencyProtocols= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'rsEEG Measurement'));
                PeakFrequencyProtocols=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(indexPeakFrequencyProtocols);
                if isempty(PeakFrequencyProtocols)
                    PeakFrequencyProtocols={'Select'};
                end
            end
            function set_PeakFrequency(source,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                if ~strcmpi(source.String,'Select') % #TODO: what if the source.string is select , then ignore this overall action)
                    montages=numel(eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels));
                    if montages>1
                        for montage=1:montages
                            montagechannels=eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels);
                            AllMontages{montage}=erase(char(join(montagechannels{montage})),' ');
                        end
                        [indx,tf] = listdlg('PromptString',{'Multiple Montages were found in your selection','Select one Montage.',''},'SelectionMode','single','ListString',AllMontages);
                        if tf==1
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{indx};
                            ImportPeakFrequencyFromMontage=AllMontages{indx};
                        elseif tf==0
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{1};
                            ImportPeakFrequencyFromMontage=AllMontages{1};
                        end
                    else
                        ImportPeakFrequencyFromMontage=erase(char(join(obj.par.(obj.info.event.current_session).(ImportPeakFrequencyFromProtocol).MontageChannels{1})),' ');
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=ImportPeakFrequencyFromMontage;
                    end
                    try
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency=obj.bst.sessions.(obj.info.event.current_session).(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol).results.PeakFrequency.(ImportPeakFrequencyFromMontage);
                    catch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency='Not Found';
                    end
                    obj.pi.drc.PeakFrequency.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency;
                end
            end
            
        end %% END obj.pi_drc
        function default_par_mepdrc(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.RealTimeChannelsMontage=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.RealTimeChannelsWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='';
            obj.info.defaults.ImportPeakFrequencyFromProtocol='';
            obj.info.defaults.ImportPeakFrequencyFromMontage='';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.EMGTargetChannels='';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.MEPOnset='15';
            obj.info.defaults.MEPOffset='50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.MEPSearchWindow='15 50';
            obj.info.defaults.EMGExtractionPeriod='-50 150';
            obj.info.defaults.EMGXLimit='-50 150';
            obj.info.defaults.EEGExtractionPeriod='-100 100';
            obj.info.defaults.EEGXLimit='-100 100';
            obj.info.defaults.EEGYLimit='-100 100';
            obj.info.defaults.DoseFunction=1;
            obj.info.defaults.ResponseFunctionNumerator='1';
            obj.info.defaults.ResponseFunctionDenominator='1';
            obj.info.defaults.EMGDisplayYLimMax={3000};
            obj.info.defaults.EMGDisplayYLimMin={-3000};
            obj.info.defaults.Protocol={'MEP Dose Response Curve Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            si=[30 40 50 60 70 80];
            for idefaults=1:6
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=50;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
                
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_mepdrc_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.drc.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.drc.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% MEP Threshold Hunting
        function pr_mth(obj)
            obj.fig.main.Widths(1:3)=[-1.15 -3.35 -0];
            obj.pi.mth.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Threshold Hunting' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mth.r0=uix.HBox( 'Parent', obj.pi.mth.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.mth.r0p1=uix.Panel( 'Parent', obj.pi.mth.r0 ,'Units','normalized');
            obj.pi.mth.r0v1 = uix.VBox( 'Parent', obj.pi.mth.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.mth.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.mth.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.mth.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Protocol and Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.mth.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.mth.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.mth.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pr_mth_conditions);%add condition
            obj.pi.mth.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pr_mth_stim); %add stimulator
            obj.pi.mth.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pr_mth_pulse); %add single pulse
            obj.pi.mth.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pr_mth_pulse);%add burst or train
            obj.pi.mth.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pr_mth_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            obj.pi.mth.r0v2 = uix.VBox( 'Parent', obj.pi.mth.r0, 'Spacing', 5, 'Padding', 0);
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.mth.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.mth.r0v2, 'Padding', 5 );
            obj.pi.mth.r0v2.Heights=[200 -1];
            set(obj.pi.mth.r0,'Widths',[-1.45 -3]);
            obj.pi.mth.cond.no=0;
            obj.cb_cm_Nconditions;
            cb_SetHeights
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.mth.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.mth.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Montage:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.RealTimeChannelsMontage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsMontage','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.RealTimeChannelsWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        obj.pi.mth.ImportPeakFrequencyFromProtocols=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8z ,'String',{'Select'},'FontSize',11,'Tag','Bin','Callback',@set_PeakFrequency);
                        obj.pi.mth.ImportPeakFrequencyFromProtocols.String=getPeakFrequencyProtocols;
                        set( mep_panel_row8z, 'Widths', [150 -2 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.PhaseTolerance=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.mth.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -3 -1]);
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 2  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( mep_panel_row2z, 'Widths', [200 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1];%[30 42 42 35 35 35 35 35 42 35];
                end
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Threshold Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
                        obj.pi.mth.ThresholdMethod=uicontrol( 'Style','popupmenu','Parent', expModr2 ,'FontSize',11,'Tag','ThresholdMethod','String',{'Adaptive Staircase Estimation', 'Maximum Likelihood Estimation'},'Callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','Trials to Average:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.NoOfTrialsToAverage=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','NoOfTrialsToAverage','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35 45 45 45 45 45];
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Threshold Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
                        obj.pi.mth.ThresholdMethod=uicontrol( 'Style','popupmenu','Parent', expModr2 ,'FontSize',11,'Tag','ThresholdMethod','String',{'Adaptive Staircase Estimation', 'Maximum Likelihood Estimation'},'Callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','MEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.MEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','MEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EMGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EEGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.EEGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[200 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 0, 'Padding', 2 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','Trials to Average:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mth.NoOfTrialsToAverage=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','NoOfTrialsToAverage','callback',@cb_par_saving);
                        expModr4.Widths=[200 -2];
                        
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -1 -1];%[30 35 42 42 42 42 42 42 42];
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.mth.r0v1,'Heights',[40 90 320 -1 55]);
                    case 2
                        set(obj.pi.mth.r0v1,'Heights',[-0.7 -8 -6 -0 -1.2])%[40 390 390 -1 55])
                        set(obj.pi.mth.r0,'Widths',[-2 -3]);
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand') || strcmp(source.Tag,'DoseFunction') || strcmp(source.Tag,'ThresholdMethod')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
            end
            function PeakFrequencyProtocols=getPeakFrequencyProtocols
                indexPeakFrequencyProtocols= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'rsEEG Measurement'));
                PeakFrequencyProtocols=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(indexPeakFrequencyProtocols);
                if isempty(PeakFrequencyProtocols)
                    PeakFrequencyProtocols={'Select'};
                end
            end
            function set_PeakFrequency(source,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                if ~strcmpi(source.String,'Select') % #TODO: what if the source.string is select , then ignore this overall action)
                    montages=numel(eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels));
                    if montages>1
                        for montage=1:montages
                            montagechannels=eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels);
                            AllMontages{montage}=erase(char(join(montagechannels{montage})),' ');
                        end
                        [indx,tf] = listdlg('PromptString',{'Multiple Montages were found in your selection','Select one Montage.',''},'SelectionMode','single','ListString',AllMontages);
                        if tf==1
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{indx};
                            ImportPeakFrequencyFromMontage=AllMontages{indx};
                        elseif tf==0
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{1};
                            ImportPeakFrequencyFromMontage=AllMontages{1};
                        end
                    else
                        ImportPeakFrequencyFromMontage=erase(char(join(obj.par.(obj.info.event.current_session).(ImportPeakFrequencyFromProtocol).MontageChannels{1})),' ');
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=ImportPeakFrequencyFromMontage;
                    end
                    try
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency=obj.bst.sessions.(obj.info.event.current_session).(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol).results.PeakFrequency.(ImportPeakFrequencyFromMontage);
                    catch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency='Not Found';
                    end
                    obj.pi.mth.PeakFrequency.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency;
                end
            end
            
        end %% END obj.pr_mth
        function default_par_mth(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.RealTimeChannelsMontage=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.RealTimeChannelsWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='';
            obj.info.defaults.ImportPeakFrequencyFromProtocol='';
            obj.info.defaults.ImportPeakFrequencyFromMontage='';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.MEPOnset='15';
            obj.info.defaults.MEPOffset='50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.MEPSearchWindow='15 50';
            obj.info.defaults.EMGExtractionPeriod='-50 150';
            obj.info.defaults.EMGXLimit='-50 150';
            obj.info.defaults.EEGExtractionPeriod='-100 100';
            obj.info.defaults.EEGXLimit='-100 100';
            obj.info.defaults.EEGYLimit='-100 100';
            obj.info.defaults.EMGDisplayYLimMax={60};
            obj.info.defaults.EMGDisplayYLimMin={-60};
            obj.info.defaults.Protocol={'Motor Threshold Hunting Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.NoOfTrialsToAverage='10';
            obj.info.defaults.MotorThreshold='NaN';
            obj.info.defaults.ThresholdMethod=1;
            obj.info.defaults.ProtocolStatus={'created'};
            si=[30];
            for idefaults=1:numel(si)
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=40;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults)};
                obj.info.defaults.condsAll.(cond).st1.threshold_level=0.05;
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_mth_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.mth.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.mth.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% Sensory Threshold Hunting
        function pr_psychmth(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.psychmth.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Sensory Threshold Hunting' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.psychmth.r0=uix.HBox( 'Parent', obj.pi.psychmth.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.psychmth.r0p1=uix.Panel( 'Parent', obj.pi.psychmth.r0 ,'Units','normalized');
            obj.pi.psychmth.r0v1 = uix.VBox( 'Parent', obj.pi.psychmth.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.psychmth.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.psychmth.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.psychmth.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Protocol and Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.psychmth.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.psychmth.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.psychmth.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pr_psychmth_conditions);%add condition
            obj.pi.psychmth.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pr_psychmth_stim); %add stimulator
            obj.pi.psychmth.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pr_psychmth_pulse); %add single pulse
            obj.pi.psychmth.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pr_psychmth_pulse);%add burst or train
            obj.pi.psychmth.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pr_psychmth_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            
            
            obj.pi.psychmth.r0v2 = uix.VBox( 'Parent', obj.pi.psychmth.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.psychmth.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.psychmth.r0v2, 'Padding', 5 );
            obj.pi.psychmth.r0v2.Heights=[200 -1];
            set(obj.pi.psychmth.r0,'Widths',[-1.45 -3]);
            obj.pi.psychmth.cond.no=0;
            obj.cb_cm_Nconditions;
            cb_SetHeights;
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.psychmth.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.psychmth.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Montage:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.RealTimeChannelsMontage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsMontage','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Real-Time Channels Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.RealTimeChannelsWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RealTimeChannelsWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        obj.pi.psychmth.ImportPeakFrequencyFromProtocols=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8z ,'String',{'Select'},'FontSize',11,'Tag','Bin','Callback',@set_PeakFrequency);
                        obj.pi.psychmth.ImportPeakFrequencyFromProtocols.String=getPeakFrequencyProtocols;
                        set( mep_panel_row8z, 'Widths', [150 -2 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.PhaseTolerance=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.psychmth.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -3 -1]);
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period(s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( mep_panel_row2z, 'Widths', [-2 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1];%[30 35 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Threshold Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
                        obj.pi.psychmth.ThresholdMethod=uicontrol( 'Style','popupmenu','Parent', expModr2 ,'FontSize',11,'Tag','ThresholdMethod','String',{'Adaptive Staircase Estimation', 'Maximum Likelihood Estimation'},'Callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Response Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.ResponsePeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','ResponsePeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        
                        expModvBox.Heights=[30 35 45];
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Threshold Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
                        obj.pi.psychmth.ThresholdMethod=uicontrol( 'Style','popupmenu','Parent', expModr2 ,'FontSize',11,'Tag','ThresholdMethod','String',{'Adaptive Staircase Estimation', 'Maximum Likelihood Estimation'},'Callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.EEGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.EEGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Response Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.psychmth.ResponsePeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','ResponsePeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        
                        expModvBox.Heights=[30 35 45 45 45];
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.psychmth.r0v1,'Heights',[40 90 140 -1 55])
                    case 2
                        set(obj.pi.psychmth.r0v1,'Heights',[-0.6 -9.4 -5.25 -0 -1.2]);
                        set(obj.pi.psychmth.r0,'Widths',[-2 -3]);
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand') || strcmp(source.Tag,'DoseFunction') || strcmp(source.Tag,'ThresholdMethod')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
            end
            function PeakFrequencyProtocols=getPeakFrequencyProtocols
                indexPeakFrequencyProtocols= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'rsEEG Measurement'));
                PeakFrequencyProtocols=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(indexPeakFrequencyProtocols);
                if isempty(PeakFrequencyProtocols)
                    PeakFrequencyProtocols={'Select'};
                end
            end
            function set_PeakFrequency(source,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                ImportPeakFrequencyFromProtocol=regexprep((source.String{source.Value}),' ','_');
                if ~strcmpi(source.String,'Select') % #TODO: what if the source.string is select , then ignore this overall action)
                    montages=numel(eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels));
                    if montages>1
                        for montage=1:montages
                            montagechannels=eval(obj.par.(obj.info.event.current_session).(regexprep((source.String{source.Value}),' ','_')).MontageChannels);
                            AllMontages{montage}=erase(char(join(montagechannels{montage})),' ');
                        end
                        [indx,tf] = listdlg('PromptString',{'Multiple Montages were found in your selection','Select one Montage.',''},'SelectionMode','single','ListString',AllMontages);
                        if tf==1
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{indx};
                            ImportPeakFrequencyFromMontage=AllMontages{indx};
                        elseif tf==0
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=AllMontages{1};
                            ImportPeakFrequencyFromMontage=AllMontages{1};
                        end
                    else
                        ImportPeakFrequencyFromMontage=erase(char(join(obj.par.(obj.info.event.current_session).(ImportPeakFrequencyFromProtocol).MontageChannels{1})),' ');
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromMontage=ImportPeakFrequencyFromMontage;
                    end
                    try
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency=obj.bst.sessions.(obj.info.event.current_session).(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ImportPeakFrequencyFromProtocol).results.PeakFrequency.(ImportPeakFrequencyFromMontage);
                    catch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency='Not Found';
                    end
                    obj.pi.psychmth.PeakFrequency.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).PeakFrequency;
                end
            end
            
        end
        function default_par_psychmth(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='40';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.RealTimeChannelsMontage=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.RealTimeChannelsWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='';
            obj.info.defaults.ImportPeakFrequencyFromProtocol='';
            obj.info.defaults.ImportPeakFrequencyFromMontage='';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.EEGExtractionPeriod='-100 100';
            obj.info.defaults.EEGXLimit='-100 100';
            obj.info.defaults.EEGYLimit='-100 100';
            obj.info.defaults.Protocol={'Psychometric Threshold Hunting Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.NoOfTrialsToAverage='10';
            obj.info.defaults.PsychometricThreshold='NaN';
            obj.info.defaults.ThresholdMethod=1;
            obj.info.defaults.ProtocolStatus={'created'};
            obj.info.defaults.ResponsePeriod='500';
            si=[1];
            for idefaults=1:numel(si)
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=50;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.threshold_level=1;
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_psychmth_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.psychmth.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.psychmth.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% rTMS Intervention
        function pi_rtms(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.rtms.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','rTMS Intervention' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.rtms.r0=uix.HBox( 'Parent', obj.pi.rtms.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.rtms.r0p1=uix.Panel( 'Parent', obj.pi.rtms.r0 ,'Units','normalized');
            obj.pi.rtms.r0v1 = uix.VBox( 'Parent', obj.pi.rtms.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.rtms.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.rtms.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.rtms.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Protocol Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.rtms.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.rtms.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.rtms.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_rtms_conditions);%add condition
            obj.pi.rtms.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_rtms_stim); %add stimulator
            obj.pi.rtms.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_rtms_pulse); %add single pulse
            obj.pi.rtms.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_rtms_pulse);%add burst or train
            obj.pi.rtms.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_rtms_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            
            obj.pi.rtms.r0v2 = uix.VBox( 'Parent', obj.pi.rtms.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.rtms.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.rtms.r0v2, 'Padding', 5 );
            obj.pi.rtms.r0v2.Heights=[200 -1];
            set(obj.pi.rtms.r0,'Widths',[-1.45 -3]);
            obj.pi.rtms.cond.no=0;
            obj.cb_cm_Nconditions;
            cb_SetHeights;
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=35;
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.rtms.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.MontageChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.MontageWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        set( mep_panel_row8z, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.PhaseTolerance=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.rtms.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -3 -1]);
                        
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period(minutes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( mep_panel_row2z, 'Widths', [150 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[30 35 35 35 35 35 35 35 42 35];
                end
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModvBox.Heights=45;
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.rtms.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModvBox.Heights=45;
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.rtms.r0v1,'Heights',[40 75 75 -3 55])
                    case 2
                        set(obj.pi.rtms.r0v1,'Heights',[40 390 75 -3 55])
                end
            end
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
        end
        function default_par_rtms(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.MontageChannels=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.MontageWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='11';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.Protocol={'rTMS Intervention Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            si=70;
            for idefaults=1:numel(si)
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={'Select'};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='train';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),5,3};
            end
            %% create an Utility Device here whose' input device type is -1
            obj.par.hardware_settings.Utility.device_type=1;
            obj.par.hardware_settings.Utility.slct_device=-1;
            obj.par.hardware_settings.Utility.device_name='Utility';
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_rtms_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.rtms.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.rtms.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% rsEEG Measurement
        function pi_rseeg(obj)
            obj.fig.main.Widths([1 2 3])=[-1.15 -3.35 -0];
            Panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','resting-state EEG Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            vb = uix.VBox( 'Parent', Panel, 'Spacing', 5, 'Padding', 5  );
            
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Spectral Analysis:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.SpectralAnalysis=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',{'IRASA','FFT'},'Tag','SpectralAnalysis','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            obj.pi.rseeg.InputDevice=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Acquisition Period (minutes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.EEGAcquisitionPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','EEGAcquisitionPeriod','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Epoch Period(s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.EEGEpochPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','EEGEpochPeriod','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Frequency Range (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.TargetFrequencyRange=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','TargetFrequencyRange','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.MontageChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.MontageWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Reference Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.ReferenceChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','ReferenceChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Recording Reference:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.RecordingReference=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RecordingReference','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','High Pass Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.HighPassFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','HighPassFrequency','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Band Stop Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.rseeg.BandStopFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','BandStopFrequency','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            %
            uiextras.HBox( 'Parent', vb);
            
            set(vb,'Heights',[35 35 45 45 45 45 45 45 45 45 45 -1])
            
            function cb_par_saving(source,~)
                source = obj.ExceptionHandling(source);
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'OutputDevice') || strcmp(source.Tag,'SpectralAnalysis')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
            end
            
        end
        function default_par_rseeg(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.SpectralAnalysis=1;
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.EEGAcquisitionPeriod='2';
            obj.info.defaults.EEGEpochPeriod='4';
            obj.info.defaults.TargetFrequencyRange='10 12';
            obj.info.defaults.ReferenceChannels='all';
            obj.info.defaults.RecordingReference='';
            obj.info.defaults.ReferenceChannels='all';
            obj.info.defaults.RecordingReference='';
            obj.info.defaults.MontageChannels='';
            obj.info.defaults.MontageWeights='';
            obj.info.defaults.HighPassFilterOrder='3';
            obj.info.defaults.HighPassFrequency='1';
            obj.info.defaults.BandStopFilterOrder='3';
            obj.info.defaults.BandStopFrequency='49 51';
            obj.info.defaults.Protocol={'rs EEG Measurement Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_rseeg_par(obj)
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    obj.pi.rseeg.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    obj.pi.rseeg.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                end
            end
        end
        %% TEP Hotspot Search
        function pi_tephs(obj)
            obj.fig.main.Widths([1 2 3])=[-1.15 -3.35 -0];
            Panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','TEP Hotspot Search' ,'FontWeight','Bold','TitlePosition','centertop');
            vb = uix.VBox( 'Parent', Panel, 'Spacing', 5, 'Padding', 5  );
            
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Electrodes Layout:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            CapLayouts={'M1-EASYCAP','64-Chanel actiCAP','r6055 NeuroScan','r6915 NeuroScan','M15-EASYCAP','M11-EASYCAP','M22-EASYCAP','M23-EASYCAP','M24-EASYCAP','M25-EASYCAP','M3-EASYCAP','M7-EASYCAP','M10-EASYCAP','M16-EASYCAP','M14-EASYCAP','M20-EASYCAP','M17-EASYCAP','M19-EASYCAP'};
            obj.pi.tephs.EEGElectrodesLayout=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',CapLayouts,'Tag','EEGElectrodesLayout','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            obj.pi.tephs.InputDevice=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.tephs.OutputDevice=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Tag','OutputDevice','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2f
            Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolMode;
            mep_panel_row_ProtocolMode_1 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row_ProtocolMode_1,'String','Protocol Mode:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.ProtocolMode=uicontrol( 'Style','popupmenu','Parent', mep_panel_row_ProtocolMode_1 ,'String',{'Automated','Manual'},'FontSize',11,'Tag','ProtocolMode','callback',@cb_par_saving,'Value',Value); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row_ProtocolMode_1, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.TargetChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','TargetChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.DisplayChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','DisplayChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Recording Reference:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.RecordingReference=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RecordingReference','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Reference Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.ReferenceChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','ReferenceChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.EEGDisplayPeriod=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','EEGDisplayPeriod','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_row4 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No. of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.TrialsPerCondition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tephs.ITI=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
            set( mep_panel_row5, 'Widths', [150 -2]);
            %
            uiextras.HBox( 'Parent', vb);
            obj.pi.tephs.ProtocolMode.Value
            if obj.pi.tephs.ProtocolMode.Value==2
                mep_panel_row4.Visible='off';
                mep_panel_row5.Visible='off';
            end
            set(vb,'Heights',[45 45 45 45 45 42 45 45 45 45 45 -1])
            Interactivity;
            function cb_run_hotspot
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ProtocolMode
                    case 1 %Automated
                        obj.bst.best_hotspot
                    case 2 %Manual
                        obj.bst.best_hotspot_manual
                end
            end
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'OutputDevice') || strcmp(source.Tag,'ProtocolMode') || strcmp(source.Tag,'EEGElectrodesLayout')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                    if strcmp(source.Tag,'ProtocolMode')
                        switch source.Value
                            case 1 % Automated
                                mep_panel_row4.Visible='on';
                                mep_panel_row5.Visible='on';
                            case 2 % Manual
                                mep_panel_row4.Visible='off';
                                mep_panel_row5.Visible='off';
                        end
                    end
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            function Interactivity
                ParametersFieldNames=fieldnames(obj.pi.tephs);
                for iLoadingParameters=1:numel(ParametersFieldNames)
                    obj.pi.tephs.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                end
            end
            
        end
        function default_par_tephs(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.EEGElectrodesLayout=1;
            obj.info.defaults.TrialsPerCondition='50';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.OutputDevice=1;
            obj.info.defaults.ProtocolMode=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.TargetChannels='';
            obj.info.defaults.DisplayChannels='';
            obj.info.defaults.RecordingReference='';
            obj.info.defaults.ReferenceChannels=' ''all'' ';
            obj.info.defaults.EEGDisplayPeriod='[-50 200]';
            obj.info.defaults.EEGDisplayYLim={NaN,NaN};
            obj.info.defaults.Protocol={'TEP Hotspot Search Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            si=NaN;
            for idefaults=1:numel(si)
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={'Select'};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults)};
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_tephs_par(obj)
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    obj.pi.tephs.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    obj.pi.tephs.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                end
            end
        end
        %% TEP Measurement
        function pi_tep(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.tep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','TMS Evoked Potentials (TEPs) Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.tep.r0=uix.HBox( 'Parent', obj.pi.tep.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.tep.r0p1=uix.Panel( 'Parent', obj.pi.tep.r0 ,'Units','normalized');
            obj.pi.tep.r0v1 = uix.VBox( 'Parent', obj.pi.tep.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.tep.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized'); % Inter Trial Inteval (s)
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.tep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.tep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            expModr2=uiextras.HBox( 'Parent', obj.pi.tep.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tep.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
            expModr2.Widths=[150 -2];
            
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.tep.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.tep.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.tep.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_tep_conditions);%add condition
            obj.pi.tep.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_tep_stim); %add stimulator
            obj.pi.tep.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_tep_pulse); %add single pulse
            obj.pi.tep.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_tep_pulse);%add burst or train
            obj.pi.tep.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_tep_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            
            obj.pi.tep.r0v2 = uix.VBox( 'Parent', obj.pi.tep.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.tep.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            table = obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.tep.r0v2, 'Padding', 5 );
            obj.pi.tep.r0v2.Heights=[200 -1];
            set(obj.pi.tep.r0,'Widths',[-1.45 -3]);
            obj.pi.tep.cond.no=0;
            obj.cb_cm_Nconditions;
            Interactivity;
            cb_SetHeights;
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.tep.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.tep.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.MontageChannels=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.MontageWeights=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        tep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', tep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( tep_panel_row8, 'Widths', [150 -2]);
                        
                        tep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.PeakFrequency=uicontrol( 'Style','edit','Parent', tep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        set( tep_panel_row8z, 'Widths', [150 -2]);
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.Phase=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.PhaseTolerance=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        % %                         tep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        % %                         uicontrol( 'Style','text','Parent', tep_panel_13,'String','Amp Distribution:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        % %                         obj.pi.tep.AmplitudeLowBound=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeLowBound','Callback',@cb_par_saving);
                        % %                         obj.pi.tep.AmplitudeHighBound=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeHighBound','Callback',@cb_par_saving);
                        % %                         obj.pi.tep.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', tep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        % %                         set( tep_panel_13, 'Widths', [150 -2 -2 -2]);
                        tep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.tep.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', tep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( tep_panel_13, 'Widths', [150 -3 -1]);
                        
                        
                        tep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2z,'String','Amp Assignment Period(minutes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', tep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( tep_panel_row2z, 'Widths', [150 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[30 35 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr3=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr3,'String','tep Onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.tepOnset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOnset','callback',@cb_par_saving);
                        obj.pi.tep.tepOffset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOffset','callback',@cb_par_saving);
                        expModr3.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.EMGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.tep.EMGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModvBox.Heights=[45 45 45];
                        %                         cb_SetHeights
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr3=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr3,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.tepOnset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOnset','callback',@cb_par_saving);
                        obj.pi.tep.tepOffset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOffset','callback',@cb_par_saving);
                        expModr3.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.EMGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.tep.EMGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.tep.EEGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.tep.EEGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModvBox.Heights=[45 45 45 45];
                        %                         cb_SetHeights
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.tep.r0v1,'Heights',[40 90 170 40 -3 55])
                    case 2
                        set(obj.pi.tep.r0v1,'Heights',[40 390 220 40 -3 55])
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            function Interactivity
                ParametersFieldNames=fieldnames(obj.pi.tep);
                for iLoadingParameters=1:numel(ParametersFieldNames)
                    try
                        obj.pi.tep.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                    catch
                    end
                end
                table.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                obj.pi.mm.tab.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
            end
            
        end
        function default_par_tep(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.MontageChannels=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.MontageWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='11';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.tepOnset='15';
            obj.info.defaults.tepOffset='50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.EMGDisplayYLimMax={3000};
            obj.info.defaults.EMGDisplayYLimMin={-3000};
            obj.info.defaults.Protocol={'tep Measurement Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            
            %             obj.info.defaults.expMode	=	1	;
            %             obj.info.defaults.inputDevice	=	1	;
            %             %             obj.info.defaults.displayChannels	=	eval('{''APBr''}')	;
            %             obj.info.defaults.trials	=	10	;
            %             obj.info.defaults.iti	=	4	;
            %             obj.info.defaults.tepOnset	=	15	;
            %             obj.info.defaults.tepOffset	=	50	;
            %             obj.info.defaults.prestim_scope_plt	=	50	;
            %             obj.info.defaults.poststim_scope_plt	=	150	;
            %             obj.info.defaults.sub_measure_str	=	'tep Measurement'	;
            %             obj.info.defaults.measure_str   =	'Multimodal Experiment'	;
            si=[30 40 50 60 70 80];
            for idefaults=1:6
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=50;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_tep_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.tep.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.tep.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% ERP Measurement
        function pi_erp(obj)
            obj.fig.main.Widths(1)=-1.15;
            obj.fig.main.Widths(2)=-3.35;
            obj.fig.main.Widths(3)=-0;
            obj.pi.erp.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Event Related Potentials (ERP) Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.erp.r0=uix.HBox( 'Parent', obj.pi.erp.panel,'Spacing', 5, 'Padding', 5 );
            obj.pi.erp.r0p1=uix.Panel( 'Parent', obj.pi.erp.r0 ,'Units','normalized');
            obj.pi.erp.r0v1 = uix.VBox( 'Parent', obj.pi.erp.r0p1, 'Spacing', 5, 'Padding', 5  );
            
            r0=uiextras.HBox( 'Parent', obj.pi.erp.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', r0,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.erp.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.erp.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.erp.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.erp.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.erp.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_erp_conditions);%add condition
            obj.pi.erp.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_erp_stim); %add stimulator
            obj.pi.erp.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_erp_pulse); %add single pulse
            obj.pi.erp.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_erp_pulse);%add burst or train
            obj.pi.erp.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_erp_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);
            
            
            
            
            obj.pi.erp.r0v2 = uix.VBox( 'Parent', obj.pi.erp.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.erp.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            table = obj.cb_cm_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.erp.r0v2, 'Padding', 5 );
            obj.pi.erp.r0v2.Heights=[200 -1];
            set(obj.pi.erp.r0,'Widths',[-1.45 -3]);
            obj.pi.erp.cond.no=0;
            obj.cb_cm_Nconditions;
            Interactivity;
            cb_SetHeights;
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.BrainState.Value;
                obj.RefreshProtocol;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.erp.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        
                        expModvBox.Heights=[30 35];
                    case 2
                        expModvBox=uix.VBox( 'Parent', BrainStateParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        %row1
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.erp.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.MontageChannels=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.MontageWeights=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        tep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', tep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( tep_panel_row8, 'Widths', [150 -2]);
                        
                        tep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.PeakFrequency=uicontrol( 'Style','edit','Parent', tep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving);
                        set( tep_panel_row8z, 'Widths', [150 -2]);
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.Phase=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving);
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        tep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.PhaseTolerance=uicontrol( 'Style','edit','Parent', tep_panel_row2 ,'FontSize',11,'Tag','PhaseTolerance','Callback',@cb_par_saving);
                        set( tep_panel_row2, 'Widths', [150 -2]);
                        
                        % %                         tep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        % %                         uicontrol( 'Style','text','Parent', tep_panel_13,'String','Amp Distribution:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        % %                         obj.pi.erp.AmplitudeLowBound=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeLowBound','Callback',@cb_par_saving);
                        % %                         obj.pi.erp.AmplitudeHighBound=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeHighBound','Callback',@cb_par_saving);
                        % %                         obj.pi.erp.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', tep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        % %                         set( tep_panel_13, 'Widths', [150 -2 -2 -2]);
                        tep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_13,'String','Amplitude Threshold:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.AmplitudeThreshold=uicontrol( 'Style','edit','Parent', tep_panel_13 ,'FontSize',11,'Tag','AmplitudeThreshold','Callback',@cb_par_saving);
                        obj.pi.erp.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', tep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( tep_panel_13, 'Widths', [150 -3 -1]);
                        
                        
                        tep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', tep_panel_row2z,'String','Amp Assignment Period(minutes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.AmplitudeAssignmentPeriod=uicontrol( 'Style','edit','Parent', tep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving);
                        set( tep_panel_row2z, 'Widths', [150 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Minimum ITI (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[30 35 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Electrodes Layout:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        CapLayouts={'M1-EASYCAP','64-Chanel actiCAP','r6055 NeuroScan','r6915 NeuroScan','M15-EASYCAP','M11-EASYCAP','M22-EASYCAP','M23-EASYCAP','M24-EASYCAP','M25-EASYCAP','M3-EASYCAP','M7-EASYCAP','M10-EASYCAP','M16-EASYCAP','M14-EASYCAP','M20-EASYCAP','M17-EASYCAP','M19-EASYCAP'};
                        obj.pi.erp.EEGElectrodesLayout=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',CapLayouts,'Tag','EEGElectrodesLayout','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.MontageChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.MontageWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Reference Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.ReferenceChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','ReferenceChannels','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_musc
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Recording Reference:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.RecordingReference=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','RecordingReference','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_mu
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','High Pass Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.HighPassFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','HighPassFrequency','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_musc
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Band Stop Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.BandStopFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','BandStopFrequency','callback',@cb_par_saving); %,'Callback',@obj.cb_hotspot_target_musc
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','SEP Search Window (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.SEPSearchWindow=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','SEPSearchWindow','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Extraction Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.EEGExtractionPeriod=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGExtractionPeriod','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.EEGXLimit=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EEGXLimit','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModvBox.Heights=[ 45 45 45 45 45 45 45 45 45 45 45];
                        
                    case 2
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr3=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr3,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.tepOnset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOnset','callback',@cb_par_saving);
                        obj.pi.erp.tepOffset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','tepOffset','callback',@cb_par_saving);
                        expModr3.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.EMGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.erp.EMGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.erp.EEGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.erp.EEGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModvBox.Heights=[45 45 45 45];
                        %                         cb_SetHeights
                end
            end
            function cb_SetHeights
                switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState
                    case 1
                        set(obj.pi.erp.r0v1,'Heights',[40 90 520 -3 55])
                    case 2
                        set(obj.pi.erp.r0v1,'Heights',[40 390 220 40 -3 55])
                end
            end
            
            
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'InputDevice') || strcmp(source.Tag,'AmplitudeUnits') || strcmp(source.Tag,'FrequencyBand')
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.Value;
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            function Interactivity
                ParametersFieldNames=fieldnames(obj.pi.erp);
                for iLoadingParameters=1:numel(ParametersFieldNames)
                    try
                        obj.pi.erp.(ParametersFieldNames{iLoadingParameters}).Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                    catch
                    end
                end
                table.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
                obj.pi.mm.tab.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
            end
            
        end
        function default_par_erp(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults=[];
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='200';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4 6';
            obj.info.defaults.ReferenceChannels='';
            obj.info.defaults.RecordingReference='';
            obj.info.defaults.MontageChannels='';
            obj.info.defaults.MontageWeights='';
            obj.info.defaults.HighPassFilterOrder='3';
            obj.info.defaults.HighPassFrequency='1';
            obj.info.defaults.BandStopFilterOrder='3';
            obj.info.defaults.BandStopFrequency='49 51';
            obj.info.defaults.Protocol={'ERP Measurement Protocol'};
            obj.info.defaults.Handles.UserData='Reserved for Future Use';
            obj.info.defaults.Enable={'on'};
            obj.info.defaults.ProtocolStatus={'created'};
            obj.info.defaults.RealTimeChannelsMontage=['{' ' ''C3'',' ' ''FC1'',' ' ''FC5'',' ' ''CP1'',' ' ''CP5''}'];
            obj.info.defaults.RealTimeChannelsWeights='1 -0.25 -0.25 -0.25 -0.25';
            obj.info.defaults.FrequencyBand=1;
            obj.info.defaults.PeakFrequency='';
            obj.info.defaults.ImportPeakFrequencyFromProtocol='';
            obj.info.defaults.ImportPeakFrequencyFromMontage='';
            obj.info.defaults.BandPassFilterOrder='80';
            obj.info.defaults.Phase='0';
            obj.info.defaults.PhaseTolerance='pi/40';
            obj.info.defaults.AmplitudeThreshold='0 1e6';
            obj.info.defaults.AmplitudeUnits=2;
            obj.info.defaults.AmplitudeAssignmentPeriod='4';
            obj.info.defaults.SEPOnset='15';
            obj.info.defaults.SEPOffset='25';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.SEPSearchWindow='15 25';
            obj.info.defaults.EEGExtractionPeriod='-20 100';
            obj.info.defaults.EEGXLimit='-20 100';
            obj.info.defaults.EEGYLimit='-100 100';
            si=[30];
            for idefaults=1:1
                cond=['cond' num2str(idefaults)];
                obj.info.defaults.condsAll.(cond).targetChannel=cellstr('NaN');
                obj.info.defaults.condsAll.(cond).TrialsPerCondition=50;
                obj.info.defaults.condsAll.(cond).ITI=[3 4];
                obj.info.defaults.condsAll.(cond).Phase='Peak';
                obj.info.defaults.condsAll.(cond).AmplitudeThreshold='0 1e6';
                obj.info.defaults.condsAll.(cond).AmplitudeUnits='Absolute (micro volts)';
                obj.info.defaults.condsAll.(cond).st1.pulse_count=1;
                obj.info.defaults.condsAll.(cond).st1.stim_device={''};
                obj.info.defaults.condsAll.(cond).st1.stim_mode='single_pulse';
                obj.info.defaults.condsAll.(cond).st1.stim_timing=num2cell(0);
                obj.info.defaults.condsAll.(cond).st1.si=si(idefaults);
                obj.info.defaults.condsAll.(cond).st1.si_units=1;
                obj.info.defaults.condsAll.(cond).st1.threshold='';
                obj.info.defaults.condsAll.(cond).st1.si_pckt={si(idefaults),[],[],[],[],[],[],[]}; % [TS PairedCS ISI TS_intendendunits CS_intendedunits ISIintendentunits TrainFreq NoOfPulses] 
                obj.info.defaults.condsAll.(cond).st1.IntensityUnit='%MSO';
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValue=NaN;
                obj.info.defaults.condsAll.(cond).st1.IntensityUnitValueUnit=NaN;
                obj.info.defaults.condsAll.(cond).st1.SessionToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ProtocolToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.ParameterToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.IntensityToCouple='none';
                obj.info.defaults.condsAll.(cond).st1.TimingOnsetUnits='ms';
                obj.info.defaults.condsAll.(cond).st1.CSUnits='';
                obj.info.defaults.condsAll.(cond).st1.ISIUnits='';
                obj.info.defaults.condsAll.(cond).st1.StimulationType='Test';
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_erp_par(obj)
            %Improvement Note: for us structuctre ki sari fieldnames k
            %equal, eik fieldname read kero usko check kero k ye string he
            %ya nahi, agr string he to assign ker do string ko , agr num he
            %to value ko assign ker do aur otherwise avoid ker do
            % run me sary pars ko inputs me pass ker do
            % factorize functiion me unko bnao jo bhi bnana he jese bhi
            % bnana he
            ParametersFieldNames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr));
            for iLoadingParameters=1:numel(ParametersFieldNames)
                if (isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'char'))
                    %                     str=['------------------ STR ' ParametersFieldNames{iLoadingParameters}]
                    obj.pi.erp.(ParametersFieldNames{iLoadingParameters}).String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'double'))
                    %                                         str=['------------------ VAL ' ParametersFieldNames{iLoadingParameters}]
                    
                    obj.pi.erp.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    if(strcmp(ParametersFieldNames{iLoadingParameters},'BrainState'))
                        obj.pi.(ParametersFieldNames{iLoadingParameters}).Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters});
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct'))
                    %Do Nothing and Just Avoid
                end
            end
            
            
        end
        %% TMS fMRI
        function pi_tmsfmri(obj)
            obj.pi.tmsfmri.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','TMS-fMRI' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.tmsfmri.vb = uix.VBox( 'Parent', obj.pi.tmsfmri.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb,'Spacing', 5, 'Padding', 5 )
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Time of Acquistion - TA (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.ta=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_ta); %,'Callback',@obj.cb_tmsfmri_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Trigger Delay (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.trigdelay=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_trigdelay);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Total Volumes:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.totalvolumes=uicontrol( 'Style','edit','Parent', mep_panel_row4,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_totalvolumes);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (volumes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.volumes_cond=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_volumes_cond,'Enable','off');
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            
            % row 3
            mep_panel_rowtf = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_rowtf,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_rowtf ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_stimulation_intensities);
            set( mep_panel_rowtf, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.tmsfmri.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            % row 12
            mep_panel_row12a = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12a,'String','Ignore Automated Updating of Stim. Itensity:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            
            obj.pi.tmsfmri.manual_stim_inten=uicontrol( 'Style','checkbox','Parent', mep_panel_row12a ,'FontSize',11,'Value',1,'Callback',@(~,~)obj.cb_pi_tmsfmri_manual_stim_inten);
            
            set( mep_panel_row12a, 'Widths', [-4 -2]);
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_tmsfmri_units_mso);
            obj.pi.tmsfmri.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_tmsfmri_units_mt);
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'Enable','off','FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_mt);
            %             obj.pi.tmsfmri.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Enable','off','Callback',@(~,~)obj.cb_pi_tmsfmri_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2]);
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb)
            
            
            % row 13a
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb)
            
            % row 13b
            uicontrol( 'Style','text','Parent',  obj.pi.tmsfmri.vb,'String','Block Design','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            % row 13c
            mep_panel_row12a = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12a,'String','Enable Block Design:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            
            obj.pi.tmsfmri.block_design=uicontrol( 'Style','checkbox','Parent', mep_panel_row12a ,'FontSize',11,'Value',0,'Callback',@(~,~)obj.cb_pi_tmsfmri_block_design);
            
            set( mep_panel_row12a, 'Widths', [-4 -2]);
            
            
            %row 13d
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Volume Vector:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.volumes_vector_full=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_volumes_vector_full);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 13e
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb)
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.tmsfmri.status_text=uicontrol( 'Style','text','Parent', mep_panel_14,'String','Status:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.status=uicontrol( 'Style','edit','Enable','off','Parent', mep_panel_14 ,'FontSize',11);
            set( mep_panel_14, 'Widths', [150 -2]);
            
            
            
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.tmsfmri.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.tmsfmri_run)
            obj.pi.tmsfmri.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.tmsfmri_stop,'Enable','on')
            set( mep_panel_17, 'Widths', [-2 -2]);
            
            set(obj.pi.tmsfmri.vb,'Heights',[-0.1 -0.6 -0.4 -0.4 -0.6 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.01 -0.2 -0.4 -0.4 -0.4 -1 -0.4 -0.5])
            
            obj.cb_pi_tmsfmri_block_design
        end
        function tmsfmri_run(obj)
            
            
            obj.pi.tmsfmri.ta.Enable='off';
            obj.pi.tmsfmri.trigdelay.Enable='off';
            obj.pi.tmsfmri.totalvolumes.Enable='off';
            obj.pi.tmsfmri.volumes_cond.Enable='off';
            obj.pi.tmsfmri.stimulation_intensities.Enable='off';
            obj.pi.tmsfmri.manual_stim_inten.Enable='off';
            obj.pi.tmsfmri.units_mso.Enable='off';
            obj.pi.tmsfmri.units_mt.Enable='off';
            obj.pi.tmsfmri.mt.Enable='off';
            obj.pi.tmsfmri.mt_btn.Enable='off';
            obj.pi.tmsfmri.run.Enable='off';
            obj.pi.tmsfmri.block_design.Enable='off';
            obj.pi.tmsfmri.volumes_vector_full.Enable='off';
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).taEnable=obj.pi.tmsfmri.ta.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelayEnable=obj.pi.tmsfmri.trigdelay.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumesEnable=obj.pi.tmsfmri.totalvolumes.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_condEnable=obj.pi.tmsfmri.volumes_cond.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable=obj.pi.tmsfmri.stimulation_intensities.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_intenEnable=obj.pi.tmsfmri.manual_stim_inten.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.tmsfmri.units_mso.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.tmsfmri.units_mt.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.tmsfmri.mt.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.tmsfmri.mt_btn.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.tmsfmri.run.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).block_designEnable=obj.pi.tmsfmri.block_design.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_vector_fullEnable=obj.pi.tmsfmri.volumes_vector_full.Enable;
            obj.pi.tmsfmri.block_design.Value
            
            
            if(obj.pi.tmsfmri.block_design.Value==1)
                delete(instrfindall);
                magventureObject = magventure('COM10'); %0808a
                magventureObject.connect;
                magventureObject.arm
                a=[];
                
                a=arduino;
                
                
                exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
                sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
                sess=obj.info.event.current_session;
                meas=obj.info.event.current_measure_fullstr;
                timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
                file_name=[exp '_' sub '_' sess '_' meas '_' time];
                
                TA=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ta; %ms old 902
                trig_delay=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelay; %ms
                
                TA=TA/1000;
                trig_delay=trig_delay/1000;
                vol_delay=TA+trig_delay-(37/1000)-0.30000
                
                total_volumes=obj.pi.tmsfmri.vol_vect(1,end);
                
                
                trial_vector=obj.pi.tmsfmri.vol_vect;
                vol_vector= obj.pi.tmsfmri.vol_vect;
                
                
                intensity_cond = obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
                intensity_cond_rep=numel(obj.pi.tmsfmri.vol_vect);
                
                intensity_vector = [];
                for i = 1:intensity_cond_rep
                    intensity_vector = [intensity_vector, intensity_cond(randperm(numel(intensity_cond)))];
                end
                intensity_vector=intensity_vector(1,1:intensity_cond_rep);
                
                trial_vector(2,:)=intensity_vector;
                %                 save([file_name '_trial_vector.mat'], 'trial_vector');
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).TrialVector=trial_vector;
                obj.cb_menu_save
                
            else
                
                delete(instrfindall);
                magventureObject = magventure('COM10'); %0808a
                magventureObject.connect;
                magventureObject.arm
                
                
                
                a=[];
                
                a=arduino;
                
                
                exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
                sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
                sess=obj.info.event.current_session;
                meas=obj.info.event.current_measure_fullstr;
                timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
                file_name=[exp '_' sub '_' sess '_' meas '_' time];
                
                TA=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ta; %ms old 902
                trig_delay=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelay; %ms
                
                TA=TA/1000;
                trig_delay=trig_delay/1000;
                vol_delay=TA+trig_delay-(37/1000)
                
                total_volumes=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumes;
                
                vol_cond = obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_cond;
                vol_cond_rep = total_volumes /  sum(vol_cond);
                vol_cond_rep=ceil(vol_cond_rep);
                
                
                vol_vector = [];
                for i = 1:vol_cond_rep
                    vol_vector = [vol_vector, vol_cond(randperm(numel(vol_cond)))];
                end
                vol_vector = cumsum(vol_vector);
                indexx=find(vol_vector>total_volumes);
                if (numel(indexx)==0)
                    indexx=numel(vol_vector);
                    trial_vector=vol_vector;
                else
                    indexx=indexx(1)-1;
                    trial_vector=vol_vector(1,1:indexx);
                    
                end
                
                intensity_cond = obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
                intensity_cond_rep = indexx /  numel(intensity_cond);
                intensity_cond_rep=ceil(intensity_cond_rep);
                
                intensity_vector = [];
                for i = 1:intensity_cond_rep
                    intensity_vector = [intensity_vector, intensity_cond(randperm(numel(intensity_cond)))];
                end
                intensity_vector=intensity_vector(1,1:indexx);
                
                trial_vector(2,:)=intensity_vector;
                %                 save([file_name '_trial_vector.mat'], 'trial_vector');
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).TrialVector=trial_vector;
                obj.cb_menu_save
                
            end
            intensitzcheck=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_inten
            if(obj.pi.tmsfmri.block_design.Value==1)
                %Indicies initilization
                set(obj.pi.tmsfmri.status,'String','Ready!');
                i=1;
                t=0;
                v=NaN(1,1000000000);
                N=0;
                %% Triggering Condition Code Burnt to Arduino
                
                while(1)
                    
                    
                    
                    t=t+1;
                    v(t)=readVoltage(a,'A5');
                    if(v(t)>3)
                        N=N+1
                        tic
                        while(1)
                            if(toc>0.30000)
                                
                                break
                            end
                        end
                        if(N==vol_vector(i))
                            i=i+1;
                            
                            tic
                            while(1)
                                if(toc>vol_delay)
                                    toc
                                    break
                                end
                            end
                            writeDigitalPin(a,'D7',1)
                            writeDigitalPin(a,'D7',0)
                            disp('triggered')
                        end
                        
                        
                        
                    end
                    if(N>=total_volumes)
                        break
                    end
                end
                
                set(obj.pi.tmsfmri.status,'String','Completed!');
            else
                if(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_inten==1)
                    
                    %Indicies initilization
                    set(obj.pi.tmsfmri.status,'String','Ready!');
                    i=1;
                    t=0;
                    v=NaN(1,1000000000);
                    N=0;
                    %% Triggering Condition Code Burnt to Arduino
                    
                    while(1)
                        
                        
                        
                        t=t+1;
                        v(t)=readVoltage(a,'A5');
                        if(v(t)>3)
                            N=N+1
                            if(N==vol_vector(i))
                                i=i+1;
                                
                                tic
                                while(1)
                                    if(toc>vol_delay)
                                        toc
                                        break
                                    end
                                end
                                
                                writeDigitalPin(a,'D7',1)
                                writeDigitalPin(a,'D7',0)
                                
                                disp('triggered')
                                
                                tic
                                while(1)
                                    if(toc>0.30000)
                                        N=N+1
                                        break
                                    end
                                end
                                
                            end
                            
                            tic
                            while(1)
                                if(toc>0.30000)
                                    
                                    break
                                end
                            end
                            
                        end
                        if(N>=total_volumes)
                            break
                        end
                    end
                    
                    set(obj.pi.tmsfmri.status,'String','Completed!');
                    
                else
                    %Indicies initilization
                    
                    i=1;
                    t=0;
                    v=NaN(1,1000000000);
                    N=0;
                    
                    
                    %% MAGVENTURE COMMANDS - uncomment to make the active, change the port number manualy
                    
                    
                    magventureObject.setAmplitude(intensity_vector(1));
                    set(obj.pi.tmsfmri.status,'String','Ready!');
                    
                    
                    
                    %% Triggering Condition Code Burnt to Arduino
                    
                    while(1)
                        
                        
                        t=t+1;
                        v(t)=readVoltage(a,'A5');
                        if(v(t)>3)
                            N=N+1
                            if(N==vol_vector(i))
                                i=i+1;
                                
                                tic
                                while(1)
                                    if(toc>vol_delay)
                                        toc
                                        break
                                    end
                                end
                                
                                writeDigitalPin(a,'D7',1)
                                writeDigitalPin(a,'D7',0)
                                
                                disp('triggered')
                                
                                tic
                                while(1)
                                    if(toc>0.30000)
                                        N=N+1
                                        %                                     intensity_vector(i)
                                        if(N<total_volumes)
                                            magventureObject.setAmplitude(intensity_vector(i));
                                            break;
                                        end
                                        break
                                    end
                                end
                                
                            end
                            
                            tic
                            while(1)
                                if(toc>0.30000)
                                    
                                    break
                                end
                            end
                            
                        end
                        if(N>=total_volumes)
                            break
                        end
                    end
                    
                    set(obj.pi.tmsfmri.status,'String','Completed!');
                end % (manual stim intensity if flag end)
            end
            
            
            set(obj.pi.tmsfmri.status,'String','Completed!');
        end % (manual stim intensity if flag end)
        function cb_pi_tmsfmri_manual_stim_inten(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_inten=(obj.pi.tmsfmri.manual_stim_inten.Value);
        end
        function cb_pi_tmsfmri_block_design (obj)
            if(obj.pi.tmsfmri.block_design.Value==1)
                obj.pi.tmsfmri.totalvolumes.Enable='off';
                obj.pi.tmsfmri.volumes_cond.Enable='off';
                obj.pi.tmsfmri.volumes_vector_full.Enable='on';
            else
                obj.pi.tmsfmri.volumes_vector_full.Enable='off';
                obj.pi.tmsfmri.totalvolumes.Enable='on';
                obj.pi.tmsfmri.volumes_cond.Enable='on';
            end
        end
        function cb_pi_tmsfmri_volumes_vector_full(obj)
            obj.pi.tmsfmri.vol_vect=evalin('base',obj.pi.tmsfmri.volumes_vector_full.String);
        end
        function func_load_tmsfmri_par(obj)
            obj.pi.tmsfmri.ta.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ta);
            obj.pi.tmsfmri.stimulation_intensities.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            obj.pi.tmsfmri.trigdelay.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelay;
            obj.pi.tmsfmri.volumes_cond.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_cond);
            obj.pi.tmsfmri.totalvolumes.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumes;
            obj.pi.tmsfmri.units_mso.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso);
            obj.pi.tmsfmri.units_mt.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt);
            obj.pi.tmsfmri.mt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt);
            %             obj.pi.tmsfmri.mt_btn.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn);
            obj.pi.tmsfmri.ta.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).taEnable;
            obj.pi.tmsfmri.trigdelay.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelayEnable;
            obj.pi.tmsfmri.totalvolumes.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumesEnable;
            obj.pi.tmsfmri.volumes_cond.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_condEnable;
            obj.pi.tmsfmri.stimulation_intensities.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable;
            obj.pi.tmsfmri.manual_stim_inten.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_intenEnable;
            obj.pi.tmsfmri.units_mso.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable;
            obj.pi.tmsfmri.units_mt.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable;
            obj.pi.tmsfmri.mt.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable;
            obj.pi.tmsfmri.mt_btn.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable;
            obj.pi.tmsfmri.run.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable;
        end
        function cb_pi_tmsfmri_ta(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ta=str2num(obj.pi.tmsfmri.ta.String);
        end
        function cb_pi_tmsfmri_stimulation_intensities(obj)
            try
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=eval(obj.pi.tmsfmri.stimulation_intensities.String);
                obj.pi.tmsfmri.run.Enable='on';
            catch
                errordlg('Warning: Wrong Input for Stim. Intensities. Make sure you are writing matrix as if you would do on MATLAB command line i.e. [20 30 40 50] not 20 30 40 50. You would not be allowed to proceed until this is fixed','BEST Toolbox');
                obj.pi.tmsfmri.run.Enable='off';
            end
        end
        function cb_pi_tmsfmri_trigdelay(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelay=str2num(obj.pi.tmsfmri.trigdelay.String);
        end
        function cb_pi_tmsfmri_volumes_cond(obj)
            try
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_cond=eval(obj.pi.tmsfmri.volumes_cond.String);
                obj.pi.tmsfmri.run.Enable='on';
                
            catch
                errordlg('Warning: Wrong Input for Inter Trial Interval. Make sure you are writing matrix as if you would do on MATLAB command line i.e. [20 30 40 50] not 20 30 40 50. You wouldnot be allowed to proceed until this is fixed.','BEST Toolbox');
                obj.pi.tmsfmri.run.Enable='off';
            end
        end
        function cb_pi_tmsfmri_totalvolumes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumes=str2num(obj.pi.tmsfmri.totalvolumes.String);
        end
        function cb_pi_tmsfmri_units_mso(obj)
            if(obj.pi.tmsfmri.units_mso.Value==1)
                obj.pi.tmsfmri.units_mt.Value=0;
                obj.pi.tmsfmri.mt.Enable='off';
            end
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=(obj.pi.tmsfmri.units_mso.Value);
        end
        function cb_pi_tmsfmri_units_mt(obj)
            if(obj.pi.tmsfmri.units_mt.Value==1)
                obj.pi.tmsfmri.units_mso.Value=0;
                obj.pi.tmsfmri.mt.Enable='on';
                
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt=(obj.pi.tmsfmri.units_mt.Value);
        end
        function cb_pi_tmsfmri_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt=str2num(obj.pi.tmsfmri.mt.String);
        end
        function cb_pi_tmsfmri_mt_btn(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=str2num(obj.pi.tmsfmri.mt_btn.String);
        end
        function default_par_tmsfmri(obj)
            %             obj.info.defaults.target_muscle='APBr';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            %             obj.info.defaults.trials_per_condition=[15];
            %             obj.info.defaults.iti=[4 6];
            %             obj.info.defaults.mep_onset=15;
            %             obj.info.defaults.mep_offset=50;
            %             obj.info.defaults.prestim_scope_ext=50;
            %             obj.info.defaults.poststim_scope_ext=150;
            %             obj.info.defaults.prestim_scope_plt=20;
            %             obj.info.defaults.poststim_scope_plt=100;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            %             obj.info.defaults.ylim_max=+5000;
            %             obj.info.defaults.ylim_min=-5000;
            %             obj.info.defaults.FontSize=14;
            %             obj.info.defaults.mt_mv=0.05;
            %             obj.info.defaults.thresholding_method=2;
            %             obj.info.defaults.trials_to_avg=15;
            %specifically for tms-fmri
            obj.info.defaults.ta=916;
            obj.info.defaults.trigdelay=14;
            obj.info.defaults.volumes_cond=[18 19 20 21 22];
            obj.info.defaults.totalvolumes=900;
            obj.info.defaults.trials_for_mean_annotation=5;
            obj.info.defaults.reset_pressed=0;
            obj.info.defaults.plot_reset_pressed=0;
            obj.info.defaults.manual_stim_inten=1;
            obj.info.defaults.save_plt=0;
            obj.info.defaults.result_mt=11;
            obj.info.defaults.mt_starting_stim_inten=25;
            obj.info.defaults.target_muscleEnable='on';
            obj.info.defaults.runEnable='on';
            obj.info.defaults.units_msoEnable='on';
            obj.info.defaults.units_mtEnable='on';
            obj.info.defaults.mtEnable='on';
            obj.info.defaults.mt_btnEnable='on';
            obj.info.defaults.prestim_scope_extEnable='on';
            obj.info.defaults.poststim_scope_extEnable='on';
            obj.info.defaults.trials_per_conditionEnable='on';
            obj.info.defaults.mt_mvEnable='on';
            obj.info.defaults.thresholding_methodEnable='on';
            obj.info.defaults.stimulation_intensitiesEnable='on';
            obj.info.defaults.taEnable='on';
            obj.info.defaults.trigdelayEnable='on';
            obj.info.defaults.totalvolumesEnable='on';
            obj.info.defaults.volumes_condEnable='on';
            obj.info.defaults.manual_stim_intenEnable='on';
            obj.info.defaults.units_msoEnable='on';
            obj.info.defaults.units_mtEnable='on';
            obj.info.defaults.mt_mvEnable='on';
            obj.info.defaults.mt_starting_stim_intenEnable='on';
            obj.info.defaults.ProtocolStatus={'created'};
            obj.info.defaults.Protocol={'TMS fMRI Protocol'};
            obj.info.defaults.Enable={'on'};
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        %% Exception Handling
        function Source= ExceptionHandling(obj,source)
            Source=source;
            Title='Guide - BEST Toolbox';
            switch source.Tag
                case 'EEGAcquisitionPeriod'
                    % Handeled Here: should be a positive number
                    % Handeled Here: should not be empty
                    % Handeled Here: should not be more than 4 minutes
                    if isempty(str2num(source.String)), Source.String=''; errordlg([Source.Tag ' shold be a positive number'],Title); end
                    if ~(str2num(source.String)>0), Source.String=''; errordlg([Source.Tag ' shold be a positive number'],Title); end
                    if str2num(source.String)>4, Source.String=''; errordlg([Source.Tag ' shold not be higher than 4 minutes due to MATLAB Samples Buffer Restrictions'],Title); end
                case 'EEGEpochPeriod'
                    % Handeled Here: should be a positive number
                    % Handeled Here: should not be empty
                    % Handeled At Run: should not be more than Acquisition Period
                    if isempty(str2num(source.String)), Source.String=''; errordlg([Source.Tag ' shold be a positive number'],Title); end
                    if ~(str2num(source.String)>0), Source.String=''; errordlg([Source.Tag ' shold be a positive number'],Title); end
                case 'TargetFrequencyRange'
                    % Handeled Here: hould be 2 positive numbers
                    % Handeled Here: Should not be more than 2
                    % Handeled Here: Should not be empty
                    % Adjusted Here: Should not contain square brackets around
                    % Adjusted Here: First one should be lower, second one should be higher
            end
        end
        %% Compile
        function Compile(obj)
        end
        %% hardware configuration panel
        function create_hwcfg_panel(obj)
            obj.hw.empty_panel=uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            set( obj.fig.main, 'Widths', [-1.15 -1.35 -2 0] );
            
            obj.hw.handle= uix.Panel( 'Parent', obj.hw.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Hardware Configuration','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.hw.hbox=uix.HBox( 'Parent', obj.hw.handle, 'Spacing', 5, 'Padding', 5  );
            obj.hw.leftpanel= uix.Panel( 'Parent', obj.hw.hbox, 'Padding', 5 ,'Units','normalized','FontWeight','bold','FontSize',14 );
            obj.hw.rightpanel= uix.Panel( 'Parent', obj.hw.hbox, 'Padding', 5 ,'Units','normalized','FontWeight','bold','FontSize',14);
            uiextras.Panel( 'Parent', obj.hw.hbox, 'BorderType','none')
            set(obj.hw.hbox,'Widths',[-2 -4 -2]);
            
            obj.hw.vbox_leftpanel=uix.VBox( 'Parent', obj.hw.leftpanel, 'Spacing', 5, 'Padding', 5  );
            % %             uicontrol( 'Style','text','Parent', obj.hw.vbox_leftpanel,'String','             Select Device Type','FontSize',12,'FontWeight','bold','HorizontalAlignment','left','Units','normalized');
            % %             obj.hw.device_type.listbox=uicontrol( 'Style','listbox','Parent', obj.hw.vbox_leftpanel ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox);
            uicontrol( 'Parent', obj.hw.vbox_leftpanel ,'Style','PushButton','String','Configure New Device','FontWeight','Bold','Callback',@(~,~)obj.cb_cfg_newdevice)
            uicontrol( 'Style','text','Parent', obj.hw.vbox_leftpanel,'String','                 Input Devices Added','FontSize',12,'FontWeight','bold','HorizontalAlignment','left','Units','normalized');
            obj.hw.device_added1_listbox.string={};
            obj.hw.device_added1.listbox=uicontrol( 'Style','listbox','Parent', obj.hw.vbox_leftpanel ,'FontSize',11,'String',obj.hw.device_added1_listbox.string,'Callback',@(~,~)obj.cb_hw_listbox_input);
            uicontrol( 'Style','text','Parent', obj.hw.vbox_leftpanel,'String','                Output Devices Added','FontSize',12,'FontWeight','bold','HorizontalAlignment','left','Units','normalized');
            obj.hw.device_added2_listbox.string={};
            obj.hw.device_added2.listbox=uicontrol( 'Style','listbox','Parent', obj.hw.vbox_leftpanel ,'FontSize',11,'String',obj.hw.device_added2_listbox.string,'Callback',@(~,~)obj.cb_hw_listbox_output);
            
            set(obj.hw.vbox_leftpanel,'Heights',[-0.5 -0.5 -3 -0.5 -3])
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            %             uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel);
            %             uicontrol( 'Style','text','Parent', obj.hw.vbox_rightpanel,'String','                                                No Device Type is selected from Left Panel','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            %             uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            %             set(obj.hw.vbox_rightpanel,'Heights',[-2 -1 -2])
            obj.hw_input_neurone
            obj.hw.output.slct_device2=1; %interim setup
            
            set( obj.fig.main, 'Widths', [-1.15 -1.35 -2 0] );
        end
        function cb_hw_device_type_listbox(obj)
            switch obj.hw.device_type.listbox.Value
                case 1
                    obj.hw_input_neurone
                case 2
                    obj.hw_output_neurone
            end
            
        end
        function cb_hw_vbox_rp_slct_device2(obj)
            obj.hw.output.slct_device2=obj.hw.vbox_rp.slct_device2.Value;
            switch obj.hw.vbox_rp.slct_device2.Value
                case {1,2,3,4}
                    obj.hw_output_pc;
                case {5,6,7,8}
                    obj.hw_output_neurone;
                case 9
                    obj.hw_output_Digitimer;
            end
        end
        function cb_cfg_newdevice(obj)
            obj.hw_input_neurone
            obj.hw.device_added1.listbox.Value=1;
            obj.hw.device_added2.listbox.Value=1;
        end
        function hw_input_neurone(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',1);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','NeurOne Protocol XML File','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Parent', row3 ,'Style','PushButton','String','Click to Attach','FontWeight','Normal','Callback',@cb_add_NeurOneProtocolFile);
            %             obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            
            
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
            function cb_add_NeurOneProtocolFile(~,~)
                [file,path] = uigetfile('*.xml');
                if (file~=0)
                    fullfilepath=[path file];
                    [clab, signaltype] = neurone_digitalout_clab_from_xml(xmlread(fullfilepath));
                    obj.hw.vbox_rp.NeurOneProtocolChannelLabels=clab; %1xn CellString
                    obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes=signaltype; %1xn CellString
                    obj.hw.vbox_rp.prtcl_name.String=file;
                else
                    errordlg('No Protocol is attached. Attach the Protocol again to add a NeurOne device','BEST Toolbox');
                end
                
                function [digitalout_clab, digitalout_signaltype] = neurone_digitalout_clab_from_xml(protocolXmlDoc)
                    % protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
                    % Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))
                    
                    % parse the NeurOne protocol in order to determine the realtime out channels
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_clab = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_clab(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('SignalType').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_signaltype = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_signaltype(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                end
            end
            
        end
        function hw_input_ft(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',2);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','Hostname','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.hostname=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','localhost');
            set(row3,'Widths',[200 -2]);
            
            row4=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row4,'String','Port Address','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.portaddress=uicontrol( 'Style','edit','Parent', row4 ,'FontSize',11,'String','1972');
            set(row4,'Widths',[200 -2]);
            
            row4=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row4,'String','Channel Labels','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.channellabels=uicontrol( 'Style','edit','Parent', row4 ,'FontSize',11,'String','1:16');
            set(row4,'Widths',[200 -2]);
            
            row4=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row4,'String','Block Size (No of samples)','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.samplesno=uicontrol( 'Style','edit','Parent', row4 ,'FontSize',11,'String','500');
            set(row4,'Widths',[200 -2]);
            
            row4=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row4,'String','Sampling Rate (Hz)','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.samplingrate=uicontrol( 'Style','edit','Parent', row4 ,'FontSize',11,'String','1000');
            set(row4,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            
            
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -1 -1 -1 -1 -5 -1])
            
        end
        function hw_input_acs(obj)
        end
        function hw_input_buttonbox(obj)
        end
        function hw_input_keyboard(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',5);
            set(row1,'Widths',[200 -2]);
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -10 -1])
        end
        function hw_input_NeurOneKeyboadMouse(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',6);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','NeurOne Protocol XML File','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Parent', row3 ,'Style','PushButton','String','Click to Attach','FontWeight','Normal','Callback',@cb_add_NeurOneProtocolFile);
            %             obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
            function cb_add_NeurOneProtocolFile(~,~)
                [file,path] = uigetfile('*.xml');
                if (file~=0)
                    fullfilepath=[path file];
                    [clab, signaltype] = neurone_digitalout_clab_from_xml(xmlread(fullfilepath));
                    obj.hw.vbox_rp.NeurOneProtocolChannelLabels=clab; %1xn CellString
                    obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes=signaltype; %1xn CellString
                    obj.hw.vbox_rp.prtcl_name.String=file;
                else
                    errordlg('No Protocol is attached. Attach the Protocol again to add a NeurOne device','BEST Toolbox');
                end
                
                function [digitalout_clab, digitalout_signaltype] = neurone_digitalout_clab_from_xml(protocolXmlDoc)
                    % protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
                    % Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))
                    
                    % parse the NeurOne protocol in order to determine the realtime out channels
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_clab = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_clab(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('SignalType').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_signaltype = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_signaltype(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                end
            end
            
        end
        function hw_input_ACSKeyboadMouse(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',7);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','NeurOne Protocol XML File','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Parent', row3 ,'Style','PushButton','String','Click to Attach','FontWeight','Normal','Callback',@cb_add_NeurOneProtocolFile);
            %             obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
            function cb_add_NeurOneProtocolFile(~,~)
                [file,path] = uigetfile('*.xml');
                if (file~=0)
                    fullfilepath=[path file];
                    [clab, signaltype] = neurone_digitalout_clab_from_xml(xmlread(fullfilepath));
                    obj.hw.vbox_rp.NeurOneProtocolChannelLabels=clab; %1xn CellString
                    obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes=signaltype; %1xn CellString
                    obj.hw.vbox_rp.prtcl_name.String=file;
                else
                    errordlg('No Protocol is attached. Attach the Protocol again to add a NeurOne device','BEST Toolbox');
                end
                
                function [digitalout_clab, digitalout_signaltype] = neurone_digitalout_clab_from_xml(protocolXmlDoc)
                    % protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
                    % Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))
                    
                    % parse the NeurOne protocol in order to determine the realtime out channels
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_clab = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_clab(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('SignalType').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_signaltype = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_signaltype(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                end
            end
            
        end
        function hw_input_ACSButtonBox(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',9);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','NeurOne Protocol XML File','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Parent', row3 ,'Style','PushButton','String','Click to Attach','FontWeight','Normal','Callback',@cb_add_NeurOneProtocolFile);
            %             obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
            function cb_add_NeurOneProtocolFile(~,~)
                [file,path] = uigetfile('*.xml');
                if (file~=0)
                    fullfilepath=[path file];
                    [clab, signaltype] = neurone_digitalout_clab_from_xml(xmlread(fullfilepath));
                    obj.hw.vbox_rp.NeurOneProtocolChannelLabels=clab; %1xn CellString
                    obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes=signaltype; %1xn CellString
                    obj.hw.vbox_rp.prtcl_name.String=file;
                else
                    errordlg('No Protocol is attached. Attach the Protocol again to add a NeurOne device','BEST Toolbox');
                end
                
                function [digitalout_clab, digitalout_signaltype] = neurone_digitalout_clab_from_xml(protocolXmlDoc)
                    % protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
                    % Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))
                    
                    % parse the NeurOne protocol in order to determine the realtime out channels
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_clab = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_clab(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('SignalType').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_signaltype = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_signaltype(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                end
            end
            
        end
        function hw_input_NeurOneButtonBox(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device controlled NeurOne','FieldTrip Real-Time Buffer','BOSS Device Controlled ActiCHamp System','Button Box','Keyboard and Mouse','BOSS Device controlled NeurOne, Keyboard and Mouse','BOSS Device controlled ActiCHamp, Keyboard and Mouse','BOSS Device controlled NeurOne and Button Box','BOSS Device controlled ActiCHamp and Button Box','Data Simulation (Reading from Disk)'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',8);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','NeurOne Protocol XML File','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Parent', row3 ,'Style','PushButton','String','Click to Attach','FontWeight','Normal','Callback',@cb_add_NeurOneProtocolFile);
            %             obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
            function cb_add_NeurOneProtocolFile(~,~)
                [file,path] = uigetfile('*.xml');
                if (file~=0)
                    fullfilepath=[path file];
                    [clab, signaltype] = neurone_digitalout_clab_from_xml(xmlread(fullfilepath));
                    obj.hw.vbox_rp.NeurOneProtocolChannelLabels=clab; %1xn CellString
                    obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes=signaltype; %1xn CellString
                    obj.hw.vbox_rp.prtcl_name.String=file;
                else
                    errordlg('No Protocol is attached. Attach the Protocol again to add a NeurOne device','BEST Toolbox');
                end
                
                function [digitalout_clab, digitalout_signaltype] = neurone_digitalout_clab_from_xml(protocolXmlDoc)
                    % protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
                    % Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))
                    
                    % parse the NeurOne protocol in order to determine the realtime out channels
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_clab = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_clab(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                    
                    inputIdNameMap = containers.Map;
                    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
                    for k = 0:allInputElements.getLength-1
                        thisElement = allInputElements.item(k);
                        inputName = thisElement.getElementsByTagName('SignalType').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('Id').item(0).getFirstChild.getData;
                        inputIdNameMap(char(inputId)) = inputName;
                    end
                    
                    outputChannelNumberNameMap = containers.Map;
                    allOutputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableOutputActive');
                    for k = 0:allOutputElements.getLength-1
                        thisElement = allOutputElements.item(k);
                        outputChannelNumber = thisElement.getElementsByTagName('OutputChannelNumber').item(0).getFirstChild.getData;
                        inputId = thisElement.getElementsByTagName('InputId').item(0).getFirstChild.getData;
                        inputName = inputIdNameMap(char(inputId));
                        outputChannelNumberNameMap(char(outputChannelNumber)) = inputName;
                    end
                    
                    sortedOutputChannels = sort(cellfun(@str2num, outputChannelNumberNameMap.keys));
                    digitalout_signaltype = [{}];
                    i = 0;
                    for channel = sortedOutputChannels
                        i = i + 1;
                        digitalout_signaltype(i) = outputChannelNumberNameMap(num2str(channel));
                    end
                    
                end
            end
            
        end
        
        function hw_bestsimulation(obj)
        end
        function hw_output_neurone(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',2);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device2=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Host PC controlled MagVenture','Host PC controlled MagStim','Host PC controlled BiStim','Host PC controlled Rapid','BOSS Box controlled MagVenture','BOSS Box controlled MagStim','BOSS Box controlled BiStim','BOSS Box controlled Rapid','Digitimer','Simulation'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device2,'Value',obj.hw.output.slct_device2);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','COM Port Address','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.comport=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','COM1');
            set(row3,'Widths',[200 -2]);
            
            row4=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row4,'String','BOSS Box Output Port Address','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.bb_outputport=uicontrol( 'Style','edit','Parent', row4 ,'FontSize',11,'String','1');
            set(row4,'Widths',[200 -2]);
            
            row5=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row5,'String','BOSS Box Input Port Address','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.bb_inputport=uicontrol( 'Style','edit','Parent', row5 ,'FontSize',11,'String','1');
            set(row5,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_output)
            
            
            
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -1 -1 -6 -1])
            
        end
        function hw_output_pc(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',2);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device2=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Host PC controlled MagVenture','Host PC controlled MagStim','Host PC controlled BiStim','Host PC controlled Rapid','BOSS Box controlled MagVenture','BOSS Box controlled MagStim','BOSS Box controlled BiStim','BOSS Box controlled Rapid','Digitimer','Simulation'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device2,'Value',obj.hw.output.slct_device2);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','COM Port Address','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.comport=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','COM1');
            set(row3,'Widths',[200 -2]);
            
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_output)
            
            
            
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -8 -1])
            
        end
        function hw_output_Digitimer(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Device Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',2);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device2=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Host PC controlled MagVenture','Host PC controlled MagStim','Host PC controlled BiStim','Host PC controlled Rapid','BOSS Box controlled MagVenture','BOSS Box controlled MagStim','BOSS Box controlled BiStim','BOSS Box controlled Rapid','Digitimer','Simulation'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device2,'Value',obj.hw.output.slct_device2);
            set(row1,'Widths',[200 -2]);
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Trigger Control','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.TriggerControl=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Device','Host PC Serial PCI Card','Host PC Parallel PCI Card','Arduino','Raspberry Pi','Manual'},'Callback',@cbTriggerControl);
            set(row1,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Intensity Control','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.IntensityControl=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Manual','Arduino'},'Callback',@cbIntensityControl);
            set(row1,'Widths',[200 -2]);
            panelTriggerControl=uix.Panel( 'Parent', obj.hw.vbox_rightpanel,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','BorderType','none','Title', 'Trigger Control Parameters','FontSize',12,'TitlePosition','centertop' );
            panelIntensityControl=uix.Panel( 'Parent', obj.hw.vbox_rightpanel,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','BorderType','none','Title', 'Intensity Control Parameters','FontSize',12,'TitlePosition','centertop');
            
            cbpanelTriggerControl
            cbpanelIntensityControl
            
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_output)
            
            set(obj.hw.vbox_rightpanel,'Heights',[35 35 35 35 35 120 120 -10 45])
            
            
            function cbTriggerControl(~,~)
                cbpanelTriggerControl
            end
            function cbIntensityControl(~,~)
                cbpanelIntensityControl
            end
            function cbpanelTriggerControl
                switch obj.hw.vbox_rp.TriggerControl.Value
                    case 1 %bossdevice
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','BOSS Device Output Port #:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.hw.vbox_rp.BOSSDevicePort=uicontrol( 'Style','edit','Parent', expModr2c ,'String','1','FontSize',11,'Tag','BOSSDevicePort','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45];
                    case 2 %host pc serial
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Host PC Serial COM Address:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        HostPCCOMPort=uicontrol( 'Style','edit','Parent', expModr2c ,'String','COM1','FontSize',11,'Tag','HostPCCOMPort','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45];
                    case 3 %host pc parallel
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Host PC Parallel LPT Address:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        HostPCLPTPort=uicontrol( 'Style','edit','Parent', expModr2c ,'String','LPT1','FontSize',11,'Tag','HostPCLPTPort','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45];
                    case 4 %arduino
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Arduino COM Port Address:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        TriggerControlArduinoCOMPort=uicontrol( 'Style','edit','Parent', expModr2c ,'String','COM1','FontSize',11,'Tag','TriggerControlArduinoCOMPort','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Arduino Digital Pin Connected to Digitmer:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        TriggerControlArduinoDigitalPin=uicontrol( 'Style','edit','Parent', expModr2c ,'String','D2','FontSize',11,'Tag','TriggerControlArduinoDigitalPin','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45 45];
                    case 5 %rpi
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Raspberry Pi Name:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        TriggerControlRasPiName=uicontrol( 'Style','edit','Parent', expModr2c ,'String','COM1','FontSize',11,'Tag','TriggerControlRasPiName','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','RasPi Digital Pin Connected to Digitmer:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        TriggerControlRasPiDigitalPin=uicontrol( 'Style','edit','Parent', expModr2c ,'String','4','FontSize',11,'Tag','TriggerControlRasPiDigitalPin','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45 45];
                    case 6 %manual
                        expModvBox=uix.VBox( 'Parent', panelTriggerControl, 'Spacing', 0, 'Padding', 0  );
                        uicontrol( 'Style','text','Parent', expModvBox,'String','Since you have chosen manual Trigger Control, an instructive dialogue box will proide instricutions to Experimenter.','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                end
            end
            function cbpanelIntensityControl
                switch obj.hw.vbox_rp.IntensityControl.Value
                    case 2 %arduino
                        expModvBox=uix.VBox( 'Parent', panelIntensityControl, 'Spacing', 0, 'Padding', 0  );
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Arduino COM Port Address:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        IntensityControlArduinoCOMPort=uicontrol( 'Style','edit','Parent', expModr2c ,'String','COM1','FontSize',11,'Tag','IntensityControlArduinoCOMPort','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Arduino Digital Pin Connected to Digitmer:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        IntensityControlArduinoDigitalPin=uicontrol( 'Style','edit','Parent', expModr2c ,'String','D2','FontSize',11,'Tag','IntensityControlArduinoDigitalPin','callback',@cbParSaving);
                        expModr2c.Widths=[200 -2];
                        expModvBox.Heights=[45 45];
                    case 1 %manual
                        expModvBox=uix.VBox( 'Parent', panelIntensityControl, 'Spacing', 0, 'Padding', 0  );
                        uicontrol( 'Style','text','Parent', expModvBox,'String','Since you have chosen manual Intensity Control, an instructive dialogue box will proide instricutions to Experimenter.','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                end
            end
            function cbParSaving(~,~)
                obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
                obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device2.Value;
                obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            end
        end
        function cb_add_output(obj)
            
            obj.hw.device_added2_listbox.string(numel(obj.hw.device_added2_listbox.string)+1)=cellstr(obj.hw.vbox_rp.device_name.String);
            obj.hw.device_added2.listbox.String=obj.hw.device_added2_listbox.string;
            if(obj.hw.device_type.listbox.Value==2)
                switch obj.hw.vbox_rp.slct_device2.Value
                    case {1,2,3,4}
                        obj.cb_hw_output_pc_parsaving;
                    case {5,6,7,8}
                        obj.cb_hw_output_neurone_parsaving;
                    case 9
                        obj.cb_hw_output_Digitimer_parsaving;
                end
            end
        end
        function cb_add_input(obj)
            
            obj.hw.device_added1_listbox.string(numel(obj.hw.device_added1_listbox.string)+1)=cellstr(obj.hw.vbox_rp.device_name.String);
            obj.hw.device_added1.listbox.String=obj.hw.device_added1_listbox.string;
            if(obj.hw.device_type.listbox.Value==1)
                switch obj.hw.vbox_rp.slct_device.Value
                    case {1,6}
                        obj.cb_hw_input_neurone_parsaving;
                    case 2
                        obj.cb_hw_input_ft_parsaving;
                    case 5
                        obj.cb_hw_input_keyboard_parsaving;
                end
            end
        end
        
        
        function cb_hw_vbox_rp_slct_device (obj)
            switch obj.hw.vbox_rp.slct_device.Value
                case 1 %NeurOne
                    obj.hw_input_neurone
                case 2 %FieldTrip
                    obj.hw_input_ft
                case 3 % ACS
                    obj.hw_input_acs;
                case 4 % ButtonBox
                    obj.hw_input_buttonbox;
                case 5 %Keyboard
                    obj.hw_input_keyboard;
                case 6 %NeurOne Keyboard
                    obj.hw_input_NeurOneKeyboadMouse;
                case 7 %ACS Keyboard
                    obj.hw_input_ACSKeyboadMouse;
                case 8 %NeurOne Button Box
                    obj.hw_input_NeurOneButtonBox;
                case 9 %ACS Button Box
                    obj.hw_input_ACSButtonBox;
                case 10 %Reading from BEST Toolbox Disk Mat File
                    obj.hw_bestsimulation;
            end
        end
        
        function cb_hw_input_neurone_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).prtcl_name=obj.hw.vbox_rp.prtcl_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).NeurOneProtocolChannelLabels=obj.hw.vbox_rp.NeurOneProtocolChannelLabels;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).NeurOneProtocolChannelSignalTypes=obj.hw.vbox_rp.NeurOneProtocolChannelSignalTypes;
        end
        function cb_hw_input_ft_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).hostname=obj.hw.vbox_rp.hostname.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).portaddress=obj.hw.vbox_rp.portaddress.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).channellabels=obj.hw.vbox_rp.channellabels.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).samplesno=obj.hw.vbox_rp.samplesno.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).samplingrate=obj.hw.vbox_rp.samplingrate.String;
        end
        function cb_hw_input_keyboard_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
        end
        function cb_hw_output_neurone_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device2.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).comport=obj.hw.vbox_rp.comport.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).bb_outputport=obj.hw.vbox_rp.bb_outputport.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).bb_inputport=obj.hw.vbox_rp.bb_inputport.String;
        end
        function cb_hw_output_pc_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device2.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).comport=obj.hw.vbox_rp.comport.String;
        end
        function cb_hw_output_Digitimer_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device2.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).TriggerControl=obj.hw.vbox_rp.TriggerControl.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).IntensityControl=obj.hw.vbox_rp.IntensityControl.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).bb_outputport=obj.hw.vbox_rp.BOSSDevicePort.String;
        end
        
        function cb_hw_listbox_input(obj)
            slctd_input=char(obj.hw.device_added1.listbox.String(obj.hw.device_added1.listbox.Value));
            
            switch obj.par.hardware_settings.(slctd_input).slct_device
                case 1 %NeurOe
                    %                     obj.cb_hw_input_neurone_parsaving;
                    obj.hw_input_neurone;
                    obj.hw.device_type.listbox.Value=obj.par.hardware_settings.(slctd_input).device_type;
                    obj.hw.vbox_rp.slct_device.Value=obj.par.hardware_settings.(slctd_input).slct_device;
                    
                    obj.hw.vbox_rp.device_name.String=obj.par.hardware_settings.(slctd_input).device_name;
                    obj.hw.vbox_rp.prtcl_name.String=obj.par.hardware_settings.(slctd_input).prtcl_name;
                    
                case 2 %FieldTrip Buffer
                    %                     obj.cb_hw_input_ft_parsaving;
                    obj.hw_input_ft;
                    obj.hw.device_type.listbox.Value=obj.par.hardware_settings.(slctd_input).device_type;
                    obj.hw.vbox_rp.slct_device.Value=obj.par.hardware_settings.(slctd_input).slct_device;
                    
                    obj.hw.vbox_rp.device_name.String=obj.par.hardware_settings.(slctd_input).device_name;
                    obj.hw.vbox_rp.hostname.String=obj.par.hardware_settings.(slctd_input).hostname;
                    obj.hw.vbox_rp.portaddress.String=obj.par.hardware_settings.(slctd_input).portaddress;
                    obj.hw.vbox_rp.channellabels.String=obj.par.hardware_settings.(slctd_input).channellabels;
                    obj.hw.vbox_rp.samplesno.String=obj.par.hardware_settings.(slctd_input).samplesno;
                    obj.hw.vbox_rp.samplingrate.String=obj.par.hardware_settings.(slctd_input).samplingrate;
                case 3 % ACS
                    obj.hw_input_acs;
                case 4 % ButtonBox
                    obj.hw_input_buttonbox;
                case 5 %Keyboard
                    obj.hw_input_keyboard;
                case 6 %Reading from BEST Toolbox Disk Mat File
                    obj.hw_bestsimulation;
            end
        end
        
        function cb_hw_listbox_output(obj)
            slctd_output=char(obj.hw.device_added2.listbox.String(obj.hw.device_added2.listbox.Value));
            switch obj.par.hardware_settings.(slctd_output).slct_device
                case {1,2,3,4}
                    obj.cb_hw_output_pc_parsaving;
                    obj.hw_output_pc;
                    obj.hw.device_type.listbox.Value=obj.par.hardware_settings.(slctd_output).device_type;
                    obj.hw.vbox_rp.slct_device2.Value=obj.par.hardware_settings.(slctd_output).slct_device;
                    
                    obj.hw.vbox_rp.device_name.String=obj.par.hardware_settings.(slctd_output).device_name;
                    obj.hw.vbox_rp.comport.String=obj.par.hardware_settings.(slctd_output).comport;
                case{5,6,7,8,9}
                    obj.cb_hw_output_neurone_parsaving;
                    obj.hw_output_neurone;
                    obj.hw.device_type.listbox.Value=obj.par.hardware_settings.(slctd_output).device_type;
                    obj.hw.vbox_rp.slct_device2.Value=obj.par.hardware_settings.(slctd_output).slct_device;
                    
                    obj.hw.vbox_rp.device_name.String=obj.par.hardware_settings.(slctd_output).device_name;
                    obj.hw.vbox_rp.comport.String=obj.par.hardware_settings.(slctd_output).comport;
                    obj.hw.vbox_rp.bb_outputport.String=obj.par.hardware_settings.(slctd_output).bb_outputport;
                    obj.hw.vbox_rp.bb_inputport.String=obj.par.hardware_settings.(slctd_output).bb_inputport;
            end
        end
        %% sessions measures listboxes
        function cb_session_add(obj)
            obj.info.session_no;
            obj.info.session_no=obj.info.session_no+1;
            
            session_name_registering=obj.pmd.sess_title.editfield.String;
            session_name_registering(session_name_registering == ' ') = '_';
            if(isvarname(session_name_registering)==0)
                errordlg('Session Title is an invalid string. It cannot be an empty sring or start with a space or numeric character, please use a meaningful string to add the intended session again.','BEST Toolbox');
                obj.info.session_no=obj.info.session_no-1;
                return
            end
            
            %             session_name_space_checking=isspace(session_name_registering)
            %             if(all(session_name_space_checking)==1) || (session_name_space_checking(1)==1)
            %                 errordlg('Session Title cannot be an empty sring or start with a space character, please use a meaningful string to add the intended session again.','BEST Toolbox');
            %                  obj.info.session_no=obj.info.session_no-1;
            %             return
            %             end
            %             session_name_registering(session_name_registering == ' ') = '_';
            %
            %             try
            %             eval(session_name_registering)
            %             errordlg('Session Title cannot be numeric data type, please use a meaningful string to add the intended session again','BEST Toolbox');
            %             obj.info.session_no=obj.info.session_no-1;
            %             return
            %             catch
            %                             end
            
            
            session_name=session_name_registering;
            
            if ~any(strcmp(obj.info.session_matrix,session_name))
                obj.info.session_matrix(obj.info.session_no)={session_name};
                obj.pmd.lb_sessions.string(obj.info.session_no)={session_name};
                obj.pmd.lb_sessions.listbox.String=obj.pmd.lb_sessions.string;
                obj.pmd.lb_sessions.listbox.Value=obj.info.session_no;
                
                
                obj.pmd.sess_title.editfield.String='';
                % % % % % % % % % % % % % % % % % % % % % % % % % %                 obj.pmd.lb_sessions.listbox.Max=2;
                % % % % % % % % % % % % % % % % % % % % % % % % % %                 obj.pmd.lb_sessions.listbox.Value=[];
                obj.data.(session_name).info.measurement_str={};
                obj.data.(session_name).info.measurement_no=0;
                obj.data.(session_name).info.measurement_str_to_listbox={};
                obj.data.(session_name).info.meas_copy_id=0;
                session_name=[];
                
                
                
            else
                obj.info.session_no=obj.info.session_no-1;
                errordlg('Session exists already with this name, please choose another name if you wish to enter a session','BEST Toolbox');
            end
            
            obj.cb_session_listbox
            % obj.cb_measure_listbox
        end
        function cb_measure_add(obj)
            if((numel(obj.pmd.lb_sessions.listbox.String))==0 || obj.info.session_no==0 || obj.pmd.lb_sessions.listbox.Value==0)
                errordlg('No session is selected for this measurement, please select a session from the listbox to proceed','BEST Toolbox');
                return
            end
            
            
            % %             obj.info.event.current_session=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value)
            % %             obj.info.event.current_session=obj.info.event.current_session{1}
            % %             obj.info.event.current_session(obj.info.event.current_session == ' ') = '_';
            
            obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no+1;
            if(obj.data.(obj.info.event.current_session).info.measurement_no==1)
                obj.data.(obj.info.event.current_session).info.meas_copy_id=0;
            end
            obj.data.(obj.info.event.current_session).info.measurement_str(1,obj.data.(obj.info.event.current_session).info.measurement_no)=obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value);
            
            
            measure_name=obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value);
            obj.data.(obj.info.event.current_session).info.measurement_str_original(1,obj.data.(obj.info.event.current_session).info.measurement_no)=measure_name;
            obj.info.event.measure_being_added_original=measure_name;
            obj.info.event.measure_being_added_original=obj.info.event.measure_being_added_original{1};
            measure_EXIST=1;
            
            if  obj.data.(obj.info.event.current_session).info.measurement_no>1
                for N= 1: obj.data.(obj.info.event.current_session).info.measurement_no-1
                    
                    measure_exist_no=(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str(N), obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value)));
                    if measure_exist_no==1
                        
                        measure_EXIST=measure_EXIST+1;
                        string_AA='_';
                        measure_name=strcat(obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value),string_AA,(num2str(measure_EXIST)));
                    end
                end
                
                
            end
            
            obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(1,obj.data.(obj.info.event.current_session).info.measurement_no)=measure_name;
            obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
            measure_name=measure_name{1};
            measure_name(measure_name == ' ') = '_';
            obj.info.event.measure_being_added=measure_name;
            obj.func_create_defaults;
            obj.cb_session_listbox;
            obj.cb_measure_listbox(obj.data.(obj.info.event.current_session).info.measurement_no);
            
            measure_name=[];
            
            
        end
        function cb_session_listbox(obj)
            if((numel(obj.pmd.lb_sessions.listbox.String))==0 || obj.info.session_no==0)
                return
            end
            
            obj.info.event.current_session=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value);
            obj.info.event.current_session=obj.info.event.current_session{1};
            obj.pmd.lb_measures.listbox.String=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox;
            obj.pmd.lb_measures.listbox.Value=1;
            
            if((numel(obj.pmd.lb_measures.listbox.String))>0)
                
                obj.cb_measure_listbox
            else
                % show the empty box over here against input panel
            end
            obj.cb_menu_save;
            %% Load Protocol Status
            obj.pmd.ProtocolStatus.listbox.String={''};
            for Prtcl=1:numel(obj.pmd.lb_measures.listbox.String)
                obj.pmd.ProtocolStatus.listbox.String(Prtcl)=obj.par.(obj.info.event.current_session).(regexprep((obj.pmd.lb_measures.listbox.String{Prtcl}),' ','_')).ProtocolStatus;
            end
            obj.pmd.ProtocolStatus.listbox.Value=obj.pmd.lb_measures.listbox.Value;
        end
        function cb_measure_listbox(obj,Value)
            if nargin==2
                obj.pmd.lb_measures.listbox.Value=Value;
            end
            if(((numel(obj.pmd.lb_measures.listbox.String))==0) || strcmp(obj.info.event.current_session,''))
                return
            end
            obj.info.event.current_measure_fullstr=obj.pmd.lb_measures.listbox.String(obj.pmd.lb_measures.listbox.Value);
            obj.info.event.current_measure_fullstr
            obj.info.event.current_measure_fullstr=obj.info.event.current_measure_fullstr{1};
            obj.info.event.current_measure_fullstr(obj.info.event.current_measure_fullstr == ' ') = '_';
            obj.info.event.current_measure_fullstr
            obj.info.event.current_measure=obj.data.(obj.info.event.current_session).info.measurement_str_original(obj.pmd.lb_measures.listbox.Value);
            obj.info.event.current_measure=obj.info.event.current_measure{1};
            obj.RefreshProtocol;
            obj.pmd.RunStopButton.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
            obj.pmd.CompileButton.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).Enable{1,1};
            %% Load Protocol Status
            obj.pmd.ProtocolStatus.listbox.String={''};
            for Prtcl=1:numel(obj.pmd.lb_measures.listbox.String)
                obj.pmd.ProtocolStatus.listbox.String(Prtcl)=obj.par.(obj.info.event.current_session).(regexprep((obj.pmd.lb_measures.listbox.String{Prtcl}),' ','_')).ProtocolStatus;
            end
            obj.pmd.ProtocolStatus.listbox.Value=obj.pmd.lb_measures.listbox.Value;
            obj.cb_menu_save;
            % obj.info.event.current_measure(obj.info.event.current_measure == ' ') = '_';
            
            
            %  obj.func_load_par
            
            %                         current_measure=obj.info.event.current_measure;
            %           obj.inputs.mep.target_muscle.String=obj.data.(obj.info.event.current_session).(current_measure).mep.target_muscle
            
            
        end
        %% load defaults and pars
        function func_create_defaults(obj)
            
            switch obj.info.event.measure_being_added_original
                case 'MEP Measurement'
                    obj.default_par_mep;
                case 'MEP Hotspot Search'
                    obj.default_par_hotspot;
                case 'MEP Motor Threshold Hunting'
                    %                     obj.default_par_mt_ptc;
                    obj.default_par_mth;
                case 'TMS fMRI'
                    obj.default_par_tmsfmri;
                case 'MEP Dose Response Curve_sp'
                    obj.default_par_ioc;
                case 'EEG triggered Stimulation'
                    obj.default_par_eegtms;
                case 'Multimodal Experiment'
                    obj.default_par_multimodal;
                case 'MEP IOC_new'
                    obj.default_par_multimodal;
                case 'MEP Dose Response Curve'
                    obj.default_par_mepdrc;
                case 'Sensory Threshold Hunting'
                    obj.default_par_psychmth;
                case 'rTMS Intervention'
                    obj.default_par_rtms;
                case 'rsEEG Measurement'
                    obj.default_par_rseeg;
                case 'TEP Hotspot Search'
                    obj.default_par_tephs;
                case 'TEP Measurement'
                    obj.default_par_tep;
                case 'ERP Measurement'
                    obj.default_par_erp;
            end
        end
        
        
        
        
        function default_par_eegtms(obj)
            obj.info.defaults.output_device='BOSSBox-MagVen'
            obj.info.defaults.input_device='BOSSBox-NeurOne'
            obj.info.defaults.target_montage='C3-Hjorth'
            obj.info.defaults.freq_ist=8
            obj.info.defaults.fre1_2nd=12
            obj.info.defaults.target_phase=[0 pi]
            obj.info.defaults.amp_low=0
            obj.info.defaults.amp_hi=1e6
            obj.info.defaults.amp_units=2
            obj.info.defaults.offset_samples=6
            obj.info.defaults.stimulation_intensities=75
            obj.info.defaults.trials_per_condition=100
            obj.info.defaults.iti=[4 6]
            obj.info.defaults.phase_tolerance=pi/50
            obj.info.defaults.units_mso=1
            obj.info.defaults.units_mt=0
            obj.info.defaults.mt=[]
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
            
        end
        
        
        
        
        
        function func_load_eegtms_par(obj)
            obj.pi.eegtms.output_device.String	=	obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device;
            obj.pi.eegtms.input_device.String	=	obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device;
            obj.pi.eegtms.target_montage.String	=	obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_montage;
            obj.pi.eegtms.freq_ist.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).freq_ist);
            obj.pi.eegtms.fre1_2nd.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).fre1_2nd);
            obj.pi.eegtms.target_phase.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_phase);
            obj.pi.eegtms.amp_low.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_low);
            obj.pi.eegtms.amp_hi.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_hi);
            
            
            obj.pi.eegtms.amp_units.Value	=	obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_units;
            obj.pi.eegtms.offset_samples.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).offset_samples);
            obj.pi.eegtms.stimulation_intensities.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            obj.pi.eegtms.trials_per_condition.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.pi.eegtms.iti.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.eegtms.phase_tolerance.String	=	num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).phase_tolerance);
            
        end
        %% Save Parameters Using Menu
        function cb_menu_save(obj)
            tic
            exp_name=obj.pmd.exp_title.editfield.String;
            exp_name(exp_name == ' ') = '_';
            
            subj_code=obj.pmd.sub_code.editfield.String;
            subj_code(subj_code == ' ') = '_';
            save_str=[exp_name '_' subj_code];
            obj.bst.info.save_str=save_str;
            
            %             variable_saved.(save_str).ExperimentName=exp_name;
            %             variable_saved.(save_str).SubjectCode=subj_code;
            %             variable_saved.(save_str).Parameters=obj.par;
            %             variable_saved.(save_str).Data=obj.bst.sessions; % 31-May-2020 00:58:42
            %
            %             variable_saved.(save_str).Utilities.Info=obj.info;
            %             variable_saved.(save_str).Utilities.Data=obj.data;
            %             variable_saved.(save_str).Utilities.Session=obj.pmd.lb_sessions.string;
            %             variable_saved.(save_str).Utilities.HardwareConfiguration.OutputDevices=obj.hw.device_added2_listbox.string;
            %             variable_saved.(save_str).Utilities.HardwareConfiguration.InputDevices=obj.hw.device_added1_listbox.string;
            BESTToolboxParameters.(save_str).ExperimentName=exp_name;
            BESTToolboxParameters.(save_str).SubjectCode=subj_code;
            BESTToolboxParameters.(save_str).Parameters=obj.par;
            BESTToolboxParameters.(save_str).Data= obj.bst.sessions; % 31-May-2020 00:58:42
            
            BESTToolboxParameters.(save_str).Utilities.Info=obj.info;
            BESTToolboxParameters.(save_str).Utilities.Data=obj.data;
            BESTToolboxParameters.(save_str).Utilities.Session=obj.pmd.lb_sessions.string;
            BESTToolboxParameters.(save_str).Utilities.HardwareConfiguration.OutputDevices=obj.hw.device_added2_listbox.string;
            BESTToolboxParameters.(save_str).Utilities.HardwareConfiguration.InputDevices=obj.hw.device_added1_listbox.string;
            
            % % % % %             drawnow
            % % % % %             if ~isempty(obj.Date)
            % % % % %                 obj.bst.info.matfilstr=['BEST_' obj.Date '_' save_str '.mat'];
            % % % % %                 obj.bst.info.save_str_runtime=['BEST_' obj.Date '_' save_str '_Autosave.mat'];
            % % % % %                 if isfile(obj.bst.info.matfilstr)
            % % % % %                     delete(obj.bst.info.matfilstr)
            % % % % %                 end
            % % % % %                 if isfile(obj.bst.info.save_str_runtime)
            % % % % %                     delete(obj.bst.info.save_str_runtime)
            % % % % %                 end
            % % % % %             end
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             if isfield(obj.bst.info,'matfilstr')
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 if isfile(obj.bst.info.matfilstr)
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                     delete(obj.bst.info.matfilstr)
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 end
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             end
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             if isfield(obj.bst.info,'save_str_runtime')
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 if isfile(obj.bst.info.save_str_runtime)
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                     delete(obj.bst.info.save_str_runtime)
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %                 end
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %             end
            % % % % % %             obj.Date=datestr(now);
            % % % % % %             obj.Date(obj.Date == ' ') = '_';
            % % % % % %             obj.Date(obj.Date == '-') = '_';
            % % % % % %             obj.Date(obj.Date == ':') = '_';
            obj.bst.info.matfilstr=['BEST_' save_str '.mat'];
            % % %             obj.bst.info.save_str_runtime=['BEST_' obj.Date '_' save_str '_Autosave.mat'];
            %             obj.bst.info.save_buffer = matfile(obj.bst.info.matfilstr,'Writable',true);
            try
                save(fullfile(obj.par.GlobalSettings.DataBaseDirectory,exp_name,obj.bst.info.matfilstr),'BESTToolboxParameters','-v7.3','-nocompression');
            catch
                if isempty(obj.par) || ~isfield(obj.par,'GlobalSettings')
                    mkdir(eval('cd'),exp_name);
                    save(fullfile(eval('cd'),exp_name,obj.bst.info.matfilstr),'BESTToolboxParameters','-v7.3','-nocompression');
                else
                    mkdir(obj.par.GlobalSettings.DataBaseDirectory,exp_name);
                    save(fullfile(obj.par.GlobalSettings.DataBaseDirectory,exp_name,obj.bst.info.matfilstr),'BESTToolboxParameters','-v7.3','-nocompression');
                end
            end
            %             obj.bst.info.save_buffer.(save_str)=variable_saved.(save_str);
            % % %
            % %
            % %             varr.info=obj.info
            % %
            % %             varr.data=obj.data
            % %
            % %             varr.bst.sessions=obj.bst.sessions
            % %
            % %
            % %             varr.bst.inputs=obj.bst.inputs
            % %
            % %             varr.bst.info=obj.bst.info
            % %             varr.bst.info.axes=[];
            % %
            % %
            % %
            % %             varr.bst.sim_mep=obj.bst.sim_mep
            % %             varr.exp_name=exp_name;
            % %             varr.subj_code=subj_code;
            %             save('C:\0. HARD DISK\BEST Toolbox\BEST-04.08\GUI\save',save_str,'obj')
            %             save(save_str,'varr')
            toc
            %             disp thistiemistakingtoolong
            
        end
        %% Load Parameters Using Menu
        function cb_menu_load(obj)
            try
                [FileName,Path] = uigetfile('*.mat', 'BEST Toolbox: Select a mat file');
                File=whos('-file',fullfile(Path,FileName));
                Filevarname=File.name;
                saved_struct=load(fullfile(Path,FileName),Filevarname);
                varname=char(fieldnames(saved_struct.BESTToolboxParameters(1)));
                obj.par=saved_struct.BESTToolboxParameters.(varname).Parameters;
                obj.info=saved_struct.BESTToolboxParameters.(varname).Utilities.Info;
                obj.data=saved_struct.BESTToolboxParameters.(varname).Utilities.Data;
                obj.bst.sessions=saved_struct.BESTToolboxParameters.(varname).Data;
                %             obj.bst.inputs=saved_struct.BESTToolboxParameters.(varname).data.global_info.inputs;
                %             obj.bst.info=saved_struct.BESTToolboxParameters.(varname).data.global_info.info;
                obj.pmd.exp_title.editfield.String=saved_struct.BESTToolboxParameters.(varname).ExperimentName;
                obj.pmd.sub_code.editfield.String=saved_struct.BESTToolboxParameters.(varname).SubjectCode;
                obj.pmd.lb_sessions.listbox.String=saved_struct.BESTToolboxParameters.(varname).Utilities.Session;
                obj.pmd.lb_sessions.string=saved_struct.BESTToolboxParameters.(varname).Utilities.Session;
                obj.hw.device_added2_listbox.string=saved_struct.BESTToolboxParameters.(varname).Utilities.HardwareConfiguration.OutputDevices;
                obj.hw.device_added1_listbox.string=saved_struct.BESTToolboxParameters.(varname).Utilities.HardwareConfiguration.InputDevices;
                
                obj.hw.device_added2.listbox.String=obj.hw.device_added2_listbox.string;
                obj.hw.device_added1.listbox.String=obj.hw.device_added1_listbox.string;
                drawnow
                pause(1);
                obj.cb_session_listbox;
                drawnow;
                %% Below Code Works for When Saved is Performed using AMAT File, but it is recommended to depricate that in Future Release because it is too slow
                %             saved_struct=load(FileName,varname);
                %             obj.par=saved_struct.(varname).Parameters;
                %             obj.info=saved_struct.(varname).Utilities.Info;
                %             obj.data=saved_struct.(varname).Utilities.Data;
                %             obj.bst.sessions=saved_struct.(varname).Data;
                % %             obj.bst.inputs=saved_struct.(varname).data.global_info.inputs;
                % %             obj.bst.info=saved_struct.(varname).data.global_info.info;
                %             obj.pmd.exp_title.editfield.String=saved_struct.(varname).ExperimentName;
                %             obj.pmd.sub_code.editfield.String=saved_struct.(varname).SubjectCode;
                %             obj.pmd.lb_sessions.listbox.String=saved_struct.(varname).Utilities.Session;
                %             obj.pmd.lb_sessions.string=saved_struct.(varname).Utilities.Session;
                % %             obj.hw=Utilities.HardwareConfiguration;
                %             obj.hw.device_added2_listbox.string=saved_struct.(varname).Utilities.HardwareConfiguration.OutputDevices;
                %             obj.hw.device_added1_listbox.string=saved_struct.(varname).Utilities.HardwareConfiguration.InputDevices;
                %
                %             obj.hw.device_added2.listbox.String=obj.hw.device_added2_listbox.string;
                %             obj.hw.device_added1.listbox.String=obj.hw.device_added1_listbox.string;
                %             drawnow
                %             pause(1);
                %             obj.cb_session_listbox;
                %             drawnow;
                
            catch e
                errordlg('You have tried to load a wrong or corrupt file. Try again with correct file.','BEST Toolbox');
                rethrow(e)
            end
            
            
            
        end
        function cb_menu_md(obj)
            obj.info.menu.md=obj.info.menu.md+1;
            if bitget(obj.info.menu.md,1) %odd
                obj.menu.md.btn.String='Open Controller';
                obj.fig.main.Widths(1)=0;
            else %even
                obj.menu.md.btn.String='Close Controller';
                obj.fig.main.Widths(1)=-1.15;
            end
        end
        function cb_menu_ip(obj)
            obj.info.menu.ip=obj.info.menu.ip+1;
            if bitget(obj.info.menu.ip,1) %odd
                obj.menu.ip.btn.String='Open Designer';
                obj.fig.main.Widths(2)=0;
            else %even
                obj.menu.ip.btn.String='Close Designer';
                obj.fig.main.Widths(2)=-1.35;
            end
        end
        function cb_menu_rp(obj)
            obj.info.menu.rp=obj.info.menu.rp+1;
            if bitget(obj.info.menu.rp,1) %odd
                obj.menu.rp.btn.String='Open Results';
                obj.fig.main.Widths(3)=0;
            else %even
                obj.menu.rp.btn.String='Close Results';
                obj.fig.main.Widths(3)=-2;
            end
        end
        
        function cb_menu_hwcfg(obj)
            obj.info.menu.hwcfg=obj.info.menu.hwcfg+1;
            if bitget(obj.info.menu.hwcfg,1) %odd
                obj.fig.main.Widths(1)=0;
                obj.fig.main.Widths(2)=0;
                obj.fig.main.Widths(3)=0;
                obj.fig.main.Widths(4)=-1;
                obj.menu.hwcfg.btn.String='Close Hardware Config';
            else %even
                obj.fig.main.Widths(1)=-1.15;
                obj.fig.main.Widths(2)=-1.35;
                obj.fig.main.Widths(3)=-2;
                obj.fig.main.Widths(4)=0;
                obj.menu.hwcfg.btn.String='Open Hardware Config';
            end
        end
        
        function best_stop(obj)
            uiresume
            obj.bst.inputs.stop_event=1;
            
        end
        
        
        
        function enable_default_fields(obj)
            obj.info.event.current_measure
            switch obj.info.event.current_measure
                case 'MEP Measurement'
                    obj.pi.mep.run.Enable='on';
                    obj.pi.mep.target_muscle.Enable='on';
                    obj.pi.mep.units_mso.Enable='on';
                    obj.pi.mep.units_mt.Enable='on';
                    obj.pi.mep.mt.Enable='on';
                    obj.pi.mep.mt_btn.Enable='on';
                    obj.pi.mep.prestim_scope_ext.Enable='on';
                    obj.pi.mep.poststim_scope_ext.Enable='on';
                    
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.mep.run.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.mep.target_muscle.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.mep.units_mso.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.mep.units_mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.mep.mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.mep.mt_btn.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.mep.prestim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.mep.poststim_scope_ext.Enable;
                    
                case 'MEP Hotspot Search'
                    obj.pi.hotspot.run.Enable='on';
                    obj.pi.hotspot.target_muscle.Enable='on';
                    obj.pi.hotspot.prestim_scope_ext.Enable='on';
                    obj.pi.hotspot.poststim_scope_ext.Enable='on';
                    
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.hotspot.run.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.hotspot.target_muscle.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.hotspot.prestim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.hotspot.poststim_scope_ext.Enable;
                    
                    
                case 'MEP Motor Threshold Hunting'
                    
                    obj.pi.mt_ptc.thresholding_method.Enable='on';
                    obj.pi.mt_ptc.mt_mv.Enable='on';
                    obj.pi.mt_ptc.run.Enable='on';
                    obj.pi.mt_ptc.target_muscle.Enable='on';
                    obj.pi.mt_ptc.trials_per_condition.Enable='on';
                    obj.pi.mt_ptc.mt_starting_stim_inten.Enable='on';
                    obj.pi.mt_ptc.prestim_scope_ext.Enable='on';
                    obj.pi.mt_ptc.poststim_scope_ext.Enable='on';
                    
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.mt_ptc.run.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.mt_ptc.target_muscle.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mvEnable=obj.pi.mt_ptc.mt_mv.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.mt_ptc.prestim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.mt_ptc.poststim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_methodEnable=obj.pi.mt_ptc.thresholding_method.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable=obj.pi.mt_ptc.trials_per_condition.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_intenEnable=obj.pi.mt_ptc.mt_starting_stim_inten.Enable;
                    
                case 'MEP Dose Response Curve_sp'
                    
                    obj.pi.ioc.run.Enable='on';
                    obj.pi.ioc.target_muscle.Enable='on';
                    obj.pi.ioc.units_mso.Enable='on';
                    obj.pi.ioc.units_mt.Enable='on';
                    obj.pi.ioc.mt.Enable='on';
                    obj.pi.ioc.mt_btn.Enable='on';
                    obj.pi.ioc.iti.Enable='on';
                    obj.pi.ioc.trials_per_condition.Enable='on';
                    obj.pi.ioc.stimulation_intensities.Enable='on';
                    obj.pi.ioc.prestim_scope_ext.Enable='on';
                    obj.pi.ioc.poststim_scope_ext.Enable='on';
                    
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.ioc.run.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.ioc.target_muscle.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.ioc.units_mso.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.ioc.units_mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.ioc.mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.ioc.mt_btn.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.ioc.prestim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.ioc.poststim_scope_ext.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable=obj.pi.ioc.trials_per_condition.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable=obj.pi.ioc.stimulation_intensities.Enable;
                    
                case 'TMS fMRI'
                    
                    obj.pi.tmsfmri.ta.Enable='on';
                    obj.pi.tmsfmri.trigdelay.Enable='on';
                    obj.pi.tmsfmri.totalvolumes.Enable='on';
                    obj.pi.tmsfmri.volumes_cond.Enable='on';
                    obj.pi.tmsfmri.stimulation_intensities.Enable='on';
                    obj.pi.tmsfmri.manual_stim_inten.Enable='on';
                    obj.pi.tmsfmri.units_mso.Enable='on';
                    obj.pi.tmsfmri.units_mt.Enable='on';
                    obj.pi.tmsfmri.mt.Enable='on';
                    obj.pi.tmsfmri.mt_btn.Enable='on';
                    obj.pi.tmsfmri.run.Enable='on';
                    
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).taEnable=obj.pi.tmsfmri.ta.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelayEnable=obj.pi.tmsfmri.trigdelay.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumesEnable=obj.pi.tmsfmri.totalvolumes.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_condEnable=obj.pi.tmsfmri.volumes_cond.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable=obj.pi.tmsfmri.stimulation_intensities.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_intenEnable=obj.pi.tmsfmri.manual_stim_inten.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.tmsfmri.units_mso.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.tmsfmri.units_mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.tmsfmri.mt.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.tmsfmri.mt_btn.Enable;
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.tmsfmri.run.Enable;
                    
                    
            end
        end
        %% Suffix at Measure
        function cb_measure_suffix(obj)
            if isempty(obj.pmd.lb_measures.listbox.String), return, end
            prompt = {'Suffix:'};
            dlgtitle = 'Protocol Suffix | BEST Toolbox';
            dims = [1 70];
            definput = {''};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            answer=char(answer);
            if isempty(answer), response=0; else, response=1; end
            switch response
                case 0
                    return
                case 1
                    str=answer;
                    CurrentMeasuresValue=obj.pmd.lb_measures.listbox.Value;
                    MeasurementStringOriginal=obj.data.(obj.info.event.current_session).info.measurement_str_original{1,CurrentMeasuresValue};
                    MeasurementStringNew=[MeasurementStringOriginal ' ' str];
                    MeasurementStringNewVar=MeasurementStringNew;
                    MeasurementStringNewVar(MeasurementStringNewVar == ' ') = '_';
                    if(isvarname(MeasurementStringNewVar)==0)
                        errordlg('Protocol suffix is an invalid string. It cannot be an empty sring or start with a space or numeric character, please use a meaningful string to add the intended suffix and try again.','BEST Toolbox');
                        return
                    end
                    ExistanceCheck=find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox, MeasurementStringNew));
                    if isempty(ExistanceCheck)
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox{1,CurrentMeasuresValue}=MeasurementStringNew;
                        obj.par.(obj.info.event.current_session).(MeasurementStringNewVar)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr);
                        obj.par.(obj.info.event.current_session)=rmfield(obj.par.(obj.info.event.current_session),obj.info.event.current_measure_fullstr);
                        try
                            obj.bst.sessions.(obj.info.event.current_session).(MeasurementStringNewVar)=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr);
                            obj.bst.sessions.(obj.info.event.current_session)=rmfield(obj.bst.sessions.(obj.info.event.current_session),obj.info.event.current_measure_fullstr);
                        catch
                        end
                        obj.cb_session_listbox
                        obj.cb_measure_listbox(CurrentMeasuresValue);
                    else
                        errordlg('Protocol exist already with this name. Please choose a different suffix to create a unique name for this protocol and try again.','BEST Toolbox');
                        return
                    end
                    
            end
        end
        %% Rename Session
        function cb_session_rename(obj)
            if isempty(obj.pmd.lb_sessions.listbox.String), return, end
            prompt = {'New Name:'};
            dlgtitle = 'Rename Session | BEST Toolbox';
            dims = [1 70];
            definput = {''};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            answer=char(answer);
            if isempty(answer), response=0; else, response=1; end
            switch response
                case 0
                    return
                case 1
                    CurrentSessionValue=obj.pmd.lb_sessions.listbox.Value;
                    session_name_registering=answer;
                    session_name_registering(session_name_registering == ' ') = '_';
                    if(isvarname(session_name_registering)==0)
                        errordlg('Session Title is an invalid string. It cannot be an empty sring or start with a space or numeric character, please use a meaningful string to add the intended session again.','BEST Toolbox');
                        obj.info.session_no=obj.info.session_no-1;
                        return
                    end
                    session_name=session_name_registering;
                    if ~any(strcmp(obj.info.session_matrix,session_name))
                        obj.info.session_matrix(CurrentSessionValue)={session_name};
                        obj.pmd.lb_sessions.string(CurrentSessionValue)={session_name};
                        obj.pmd.lb_sessions.listbox.String=obj.pmd.lb_sessions.string;
                        try
                            obj.par.(session_name)=obj.par.(obj.info.event.current_session);
                            obj.par=rmfield(obj.par,obj.info.event.current_session);
                        catch
                        end
                        try
                            obj.bst.sessions.(session_name)=obj.bst.sessions.(obj.info.event.current_session);
                            obj.bst.sessions=rmfield(obj.bst.sessions,obj.info.event.current_session);
                        catch
                        end
                        obj.data.(session_name)=obj.data.(obj.info.event.current_session);
                        obj.data=rmfield(obj.data,obj.info.event.current_session);
                        obj.cb_session_listbox
                    else
                        errordlg('Session exists already with this name, please choose another name if you wish to enter a session','BEST Toolbox');
                    end
            end
        end
        %% Rename Measure
        function cb_measure_rename(obj)
            if isempty(obj.pmd.lb_measures.listbox.String), return, end
            prompt = {'New Name:'};
            dlgtitle = 'Rename Protocol | BEST Toolbox';
            dims = [1 70];
            definput = {''};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            answer=char(answer);
            if isempty(answer), response=0; else, response=1; end
            switch response
                case 0
                    return
                case 1
                    str=answer;
                    CurrentMeasuresValue=obj.pmd.lb_measures.listbox.Value;
                    MeasurementStringOriginal=obj.data.(obj.info.event.current_session).info.measurement_str_original{1,CurrentMeasuresValue};
                    MeasurementStringNew=str;
                    MeasurementStringNewVar=MeasurementStringNew;
                    MeasurementStringNewVar(MeasurementStringNewVar == ' ') = '_';
                    if(isvarname(MeasurementStringNewVar)==0)
                        errordlg('Protocol Name is an invalid string. It cannot be an empty sring or start with a space or numeric character, please use a meaningful string to add the intended suffix and try again.','BEST Toolbox');
                        return
                    end
                    ExistanceCheck=find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox, MeasurementStringNew));
                    if isempty(ExistanceCheck)
                        obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox{1,CurrentMeasuresValue}=MeasurementStringNew;
                        obj.par.(obj.info.event.current_session).(MeasurementStringNewVar)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr);
                        obj.par.(obj.info.event.current_session)=rmfield(obj.par.(obj.info.event.current_session),obj.info.event.current_measure_fullstr);
                        try
                            obj.bst.sessions.(obj.info.event.current_session).(MeasurementStringNewVar)=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr);
                            obj.bst.sessions.(obj.info.event.current_session)=rmfield(obj.bst.sessions.(obj.info.event.current_session),obj.info.event.current_measure_fullstr);
                        catch
                        end
                        obj.cb_session_listbox
                        obj.cb_measure_listbox(CurrentMeasuresValue);
                    else
                        errordlg('Protocol exist already with this name. Please choose a different suffix to create a unique name for this protocol and try again.','BEST Toolbox');
                        return
                    end
            end
        end
        %% Toolbox Settings
        function cb_menu_settings(obj)
            obj.info.menu.hwcfg=obj.info.menu.hwcfg+1;
            if bitget(obj.info.menu.hwcfg,1) %odd
                obj.fig.main.Widths([1 2 3])=[0 -3.35 -0];
                obj.menu.settings.btn.String='Close Settings';
                obj.pi_ToolboxSetings;
                obj.func_load_ToolboxSetings;
            else %even
                obj.fig.main.Widths([1 2 3])=[-1 -3.35 -0];
                obj.menu.settings.btn.String='Open Settings';
                obj.pi.no_measure_slctd_panel.handle=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Protocol Designer','FontWeight','Bold','TitlePosition','centertop' );
                obj.pi.no_measure_slctd_panel.vbox = uix.VBox( 'Parent', obj.pi.no_measure_slctd_panel.handle, 'Spacing', 5, 'Padding', 5  );
                uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox)
                uicontrol( 'Parent', obj.pi.no_measure_slctd_panel.vbox,'Style','text','String','No Protocol is selected','FontSize',11,'HorizontalAlignment','center','Units','normalized' );
                uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox);
                %           obj.panel.st=set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
                set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
            end
        end
        function pi_ToolboxSetings(obj)
            obj.fig.main.Widths([1 2 3])=[0 -3.35 -0];
            Panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Toolbox Global Settings' ,'FontWeight','Bold','TitlePosition','centertop');
            vb = uix.VBox( 'Parent', Panel, 'Spacing', 5, 'Padding', 5  );
            obj.pi.settings.Apply50HZLineNoiseFilter=uicontrol( 'Style','checkbox','Parent', vb ,'FontSize',11,'String','Apply 50HZ Line Noise Filter to EMG Data:','Tag','NoiseFilter50Hz','callback',@cb_par_saving);
            obj.pi.settings.Apply60HZLineNoiseFilter=uicontrol( 'Style','checkbox','Parent', vb ,'FontSize',11,'String','Apply 60HZ Line Noise Filter to EMG Data:','Tag','NoiseFilter60Hz','callback',@cb_par_saving);
            obj.pi.settings.SaveFiguresofeachProtocol=uicontrol( 'Style','checkbox','Parent', vb ,'FontSize',11,'String','Save Figures of each Protocol:','Tag','SaveFiguresofeachProtocol','callback',@cb_par_saving);
            HBox=uix.HBox('Parent',vb,'Spacing', 5  );
            uicontrol( 'Style','text','Parent', HBox,'String','Database Directory:','FontSize',11,'HorizontalAlignment','left','Units','normalized' );
            obj.pi.settings.DataBaseDirectory=uicontrol( 'Style','edit','Parent', HBox ,'String','cd','Tag','DataBaseDirectory','FontSize',11,'Callback',@cb_par_saving);
            HBox.Widths=[-0.3 -1];
            uiextras.HBox( 'Parent', vb);
            set( vb, 'Heights', [100 100 100 30 -1]);
            CreateDefaultsIfRequired;
            function cb_par_saving(source,~)
                if strcmp(source.Tag,'DataBaseDirectory')
                    if exist(source.String, 'dir')==7
                        obj.par.GlobalSettings.DataBaseDirectory=source.String;
                    else
                        obj.par.GlobalSettings.DataBaseDirectory=eval('cd');
                        obj.pi.settings.DataBaseDirectory.String=obj.par.GlobalSettings.DataBaseDirectory;
                    end
                else
                    obj.par.GlobalSettings.(source.Tag)=source.Value;
                end
            end
            function CreateDefaultsIfRequired
                if ~isfield(obj.par,'GlobalSettings') || isempty(obj.par)
                    obj.par.GlobalSettings.NoiseFilter50Hz=0;
                    obj.par.GlobalSettings.NoiseFilter60Hz=0;
                    obj.par.GlobalSettings.SaveFigures=1;
                    obj.par.GlobalSettings.DataBaseDirectory=eval('cd');
                end
            end
        end
        function func_load_ToolboxSetings(obj)
            ParametersFieldNames=fieldnames(obj.pi.settings);
            for iLoadingParameters=1:numel(ParametersFieldNames)
                switch ParametersFieldNames{iLoadingParameters}
                    case 'Apply50HZLineNoiseFilter'
                        obj.pi.settings.(ParametersFieldNames{iLoadingParameters}).Value= obj.par.GlobalSettings.NoiseFilter50Hz;
                    case 'Apply60HZLineNoiseFilter'
                        obj.pi.settings.(ParametersFieldNames{iLoadingParameters}).Value= obj.par.GlobalSettings.NoiseFilter60Hz;
                    case 'SaveFiguresofeachProtocol'
                        obj.pi.settings.(ParametersFieldNames{iLoadingParameters}).Value= obj.par.GlobalSettings.SaveFigures;
                    case 'DataBaseDirectory'
                        obj.pi.settings.(ParametersFieldNames{iLoadingParameters}).String=obj.par.GlobalSettings.DataBaseDirectory;
                end
            end
        end
        %% Notes
        function cb_notes(obj)
            d=figure('units','normalized','position',[0.1 0.1 0.8 0.8],'menubar','none','resize','off','numbertitle','off','name','Notes | BEST Toolbox','WindowStyle','modal');
            editfield=uicontrol('style','edit','units','normalized','position',[0.01 0.01 0.98 0.98],'HorizontalAlign','left','min',1,'max',4,'FontSize',13','CreateFcn',@CreateNotes,'KeyPressFcn',@NotesKeyPress);
            uicontrol(d);
            function NotesKeyPress(src,evt)
                uicontrol(editfield);
                if strcmp(evt.Key,'delete') || strcmp(evt.Key,'backspace')
                    if isempty(src.String{end})
                        idx=size(src.String,1)-1;
                    else
                        idx=size(src.String,1);
                    end
                    src.String{idx}=src.String{idx}(1:end-1);
                    src.String(strcmp('',src.String)) = [];
                elseif strcmp(evt.Key,'return')
                    datetimevec=char(datetime('now')); datetimevec=[datetimevec '   -   '];
                    src.String{end+1}=datetimevec;
                else
                    src.String{end}=[src.String{end} evt.Character];
                end
                obj.par.Notes=src.String;
            end
            function CreateNotes(src,~)
                try
                    src.String=obj.par.Notes;
                catch
                end
                if isempty(src.String)
                    datetimevec=char(datetime('now'));
                    datetimevec=[datetimevec '   -   '];
                    src.String{1}=[datetimevec src.String];
                elseif ~isempty(src.String)
                    datetimevec=char(datetime('now')); datetimevec=[datetimevec '   -   '];
                    src.String{end+1}=datetimevec;
                end
            end
        end
        %% Condition Maker
        function table= cb_cm_StimulationParametersTable(obj)
            iData=0;
            ColCondition=1;
            ColNoOfTrials=ColCondition+1;
            ColITI=ColNoOfTrials+1;
            if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState==2, ColPhase=ColITI+1; ColAmp=ColPhase+1; ColAmpUnits=ColAmp+1;else, ColPhase=ColITI; ColAmp=ColPhase; ColAmpUnits=ColAmp; end %if
            ColTS=ColAmpUnits+1;
            ColStimType=ColTS+1;
            if strcmp(obj.info.event.current_measure,'MEP Motor Threshold Hunting'), ColThresholdLevel=ColStimType+1; else, ColThresholdLevel=ColStimType; end
            ColIntensityUnits=ColThresholdLevel+1;
            ColStimulator=ColIntensityUnits+1;
            ColPulseMode=ColStimulator+1;
            ColNoOfPulses=ColPulseMode+1;
            ColTimingOnset=ColNoOfPulses+1;
            ColTimingOnsetUnits=ColTimingOnset+1;
            if ~(strcmp(obj.info.event.current_measure,'MEP Dose Response Curve') || strcmp(obj.info.event.current_measure,'ERP Measurement') || strcmp(obj.info.event.current_measure,'TEP Measurement')), ColTargetChannel=ColTimingOnsetUnits+1; else, ColTargetChannel=ColTimingOnsetUnits; end
            ColCS=ColTargetChannel+1;
            ColCSUnits=ColCS+1;
            ColISI=ColCSUnits+1;
            ColISIUnits=ColISI+1;
            ColTrainFreq=ColISIUnits+1;
            ColNoOfTrains=ColTrainFreq+1;
            ColFixedThreshold=ColNoOfTrains+1;
            TableData=cell(1,1);ColumnName=cell(1,1);ColumnFormat=cell(1,1);    
            for iTableCondition=1:numel(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll))
                TableCond=['cond' num2str(iTableCondition)];
                for iTableStimulator=1:numel(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond)))-6 
                    iData=iData+1;
                    TableStim=['st' num2str(iTableStimulator)];
                    TableData{iData,ColCondition}=num2str(iTableCondition);
                    TableData{iData,ColNoOfTrials}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).TrialsPerCondition);
                    TableData{iData,ColITI}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).ITI);
                    ColumnName{ColCondition}='Condition #'; ColumnFormat{ColCondition}=[];
                    ColumnName{ColNoOfTrials}='No of Trials'; ColumnFormat{ColNoOfTrials}=[];
                    ColumnName{ColITI}='ITI (s)'; ColumnFormat{ColITI}=[];
                    if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState==2
                        TableData{iData,ColPhase}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).Phase;
                        TableData{iData,ColAmp}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).AmplitudeThreshold;
                        TableData{iData,ColAmpUnits}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).AmplitudeUnits;
                        ColumnName{ColPhase}='Phase'; ColumnFormat{ColPhase}={'Peak','Trough','RisingFlank','FallingFlank','Random'};
                        ColumnName{ColAmp}='Amplitude Threshold'; ColumnFormat{ColAmp}=[];
                        ColumnName{ColAmpUnits}='Amplitude Units'; ColumnFormat{ColAmpUnits}={'Absolute (micro volts)','Percentile'};
                        ColumnName{ColITI}='Min. ITI (s)';
                    end
                    TableData{iData,ColTS}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,1});
                    TableData{iData,ColStimType}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).StimulationType;
                    ColumnName{ColTS}='Stim. Intensity'; ColumnFormat{ColTS}=[];
                    ColumnName{ColStimType}='Stim. Type'; ColumnFormat{ColStimType}={'Test','Condition','Other'};
                    if strcmp(obj.info.event.current_measure,'MEP Motor Threshold Hunting')
                        TableData{iData,ColThresholdLevel}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).threshold_level);
                        ColumnName{ColThresholdLevel}='Threshold Level (mV)'; ColumnFormat{ColThresholdLevel}=[];
                        ColumnName{ColTS}='Starting Intensity';
                    end
                    TableData{iData,ColIntensityUnits}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).IntensityUnit;
                    TableData{iData,ColStimulator}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_device{1,1};
                    TableData{iData,ColPulseMode}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_mode;
                    TableData{iData,ColNoOfPulses}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).pulse_count); 
                    TableData{iData,ColTimingOnset}=mat2str(cell2mat(horzcat((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_timing(1,:)))));
                    TableData{iData,ColTimingOnsetUnits}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).TimingOnsetUnits;
                    ColumnName{ColIntensityUnits}='Intensity Units'; ColumnFormat{ColIntensityUnits}={'%MSO','%MT','mA','%ST','%MSO coupled','%MT coupled','mA coupled','%ST coupled'};
                    ColumnName{ColStimulator}='Stimulator'; ColumnFormat{ColStimulator}=[{'Select'}, obj.hw.device_added2_listbox.string];
                    ColumnName{ColPulseMode}='Pulse Mode'; ColumnFormat{ColPulseMode}={'single_pulse','paired_pulse', 'train'};
                    ColumnName{ColTimingOnset}='Timing Onset'; ColumnFormat{ColTimingOnset}=[];
                    ColumnName{ColTimingOnsetUnits}='Timing Onset Units'; ColumnFormat{ColTimingOnsetUnits}={'ms','ms coupled'};
                    ColumnName{ColNoOfPulses}='# of Pulses'; ColumnFormat{ColNoOfPulses}=[];
                    if ~(strcmp(obj.info.event.current_measure,'MEP Dose Response Curve') || strcmp(obj.info.event.current_measure,'ERP Measurement') || strcmp(obj.info.event.current_measure,'TEP Measurement'))
                        TableData{iData,ColTargetChannel}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).targetChannel{1,1};
                        ColumnName{ColTargetChannel}='Target Channel'; ColumnFormat{ColTargetChannel}=[];
                    end
                    TableData{iData,ColCS}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,2});
                    TableData{iData,ColCSUnits}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).CSUnits);
                    TableData{iData,ColISI}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,3});
                    TableData{iData,ColISIUnits}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).ISIUnits);
                    TableData{iData,ColTrainFreq}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,7});
                    TableData{iData,ColNoOfTrains}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,8});
                    TableData{iData,ColFixedThreshold}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).threshold;
                    ColumnName{ColCS}='Paired-CS Intensity'; ColumnFormat{ColCS}=[];
                    ColumnName{ColCSUnits}='Paired-CS Intensity Units'; ColumnFormat{ColCSUnits}={'%MSO','%MT','mA','%ST','%MSO coupled','%MT coupled','mA coupled','%ST coupled'};
                    ColumnName{ColISI}='ISI'; ColumnFormat{ColISI}=[]; 
                    ColumnName{ColISIUnits}='ISI Units'; ColumnFormat{ColISIUnits}={'ms','ms coupled'};
                    ColumnName{ColTrainFreq}='Train Frequency'; ColumnFormat{ColTrainFreq}=[];
                    ColumnName{ColNoOfTrains}='# of Trains'; ColumnFormat{ColNoOfTrains}=[];
                    ColumnName{ColFixedThreshold}='Threshold'; ColumnFormat{ColFixedThreshold}=[];
                end
            end
            % create the table and write data in table
            table=uitable( 'Parent', obj.pi.mm.r0v2r1);
            table.Data=TableData;
            table.FontSize=10;
            table.ColumnName = ColumnName;
            table.ColumnFormat= ColumnFormat;
            table.ColumnWidth = repmat({100},1,numel(table.ColumnName)); 
            table.ColumnEditable =true(1,numel(table.ColumnName));
            table.RowStriping='on';
            table.RearrangeableColumns='on';
            table.CellEditCallback =@CellEditCallback ;
            
            function CellEditCallback (~,CellEditData)
                AdditionInCondition=['cond' num2str(table.Data{CellEditData.Indices(1),1})];
                AdditionInStimulatorNum=find(find(cellfun(@str2double ,table.Data(:,1))==str2double(table.Data{CellEditData.Indices(1),1}))==CellEditData.Indices(1));
                AdditionInStimulator=['st' num2str(AdditionInStimulatorNum)];
                opts=[]; opts.WindowStyle='modal'; opts.Interpreter='none';
                switch table.ColumnName{1,CellEditData.Indices(2)}
                    case 'No of Trials'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).TrialsPerCondition=str2num(CellEditData.NewData);
                    case {'ITI (s)','Min. ITI (s)'}
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).ITI=str2num(CellEditData.NewData);
                    case 'Phase'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).Phase=CellEditData.NewData;
                    case 'Amplitude Threshold'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).AmplitudeThreshold=str2num(CellEditData.NewData);
                    case 'Amplitude Units'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).AmplitudeUnits=CellEditData.NewData;
                    case {'Stim. Intensity','Starting Intensity'}
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,1}=str2double(CellEditData.NewData);
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si=CellEditData.NewData;
                    case 'Stim. Type'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).StimulationType=CellEditData.NewData;
                    case 'Threshold Level (mV)'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold_level=str2num(CellEditData.NewData);
                    case 'Intensity Units'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).IntensityUnit=CellEditData.NewData;
                    case 'Stimulator'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_device=cellstr(CellEditData.NewData);
                    case 'Pulse Mode'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode=CellEditData.NewData;
                    case '# of Pulses'
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).pulse_count=str2num(CellEditData.NewData);
                    case 'Timing Onset'
                        %% start here
                    case 'Timing Onset Units'
                    case 'Target Channel'
                    case 'Paired-CS Intensity'
                    case 'Paired-CS Intensity Units'
                    case 'ISI'
                    case 'ISI Units'
                    case 'Train Frequency'
                    case '# of Trains'
                    case 'Threshold'
                
                        
                        
                        
                        
                    case ColTS %TS Intensity
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,1}=str2double(CellEditData.NewData);
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si=CellEditData.NewData;
                    case ColThresholdLevel
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold_level=str2double(CellEditData.NewData);
                    case ColIntensityUnits %Intensity Units
                        switch CellEditData.NewData
                            case '%MSO'
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_units=1;
                            case '%MT'
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_units=0;
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold='NaN';
                                
                        end
                        
                    case ColStimulator %Stimulator
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_device=cellstr(CellEditData.NewData);
                        
                    case ColPulseMode %Pulse Mode
                        switch CellEditData.NewData
                            case 'Single Pulse'
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='single_pulse';
                            case 'Paired Pulse'
                                
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='paired_pulse';
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=NaN;
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=NaN;
                                
                            case 'Train'
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='train';
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=NaN;
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=NaN;
                        end
                        
                    case ColNoOfPulses % # of Pulses
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).pulse_count=str2double(CellEditData.NewData);
                        %AAJ: idher add kero k Stimulation Mode bhi nill ho jaye units bhi Nill ho
                        %jaye intensity bhi khtam ho jaye matlab jese he pulse 0 zero ho to sirf vo
                        %reh jaye to jab only stimulator add kerty hein to ata he
                        if(str2double(CellEditData.NewData)==0)
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing{1,1}=[];
                        else
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing{1,str2double(CellEditData.NewData)}=NaN;
                        end
                        
                    case ColTimingOnset %Timing Onset (ms)
                        CellEditDataTimingOnset=[];
                        CellEditDataTimingOnset=num2cell(eval(CellEditData.NewData));
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing=CellEditDataTimingOnset;
                        
                    case ColTargetChannel %Target EMG Ch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).targetChannel=cellstr(CellEditData.NewData);
                        
                    case {ColTrainFreq,ColNoOfTrains} %Train Freq, # of Trians
                        if ~(strcmp(table.Data{CellEditData.Indices(1),5},'Train'))
                            table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                            errordlg('Train Frequency and # of Trians are only Editable for the "Train" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
                        else
                            switch CellEditData.Indices(2)
                                case ColTrainFreq
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=str2double(CellEditData.NewData);
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).freq=CellEditData.NewData;
                                case ColNoOfTrains
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=str2double(CellEditData.NewData);
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).pulsesNo=CellEditData.NewData;
                            end
                            
                        end
                    case {ColCS,ColISI} % CS Intensity, ISI (ms)
                        if ~(strcmp(table.Data{CellEditData.Indices(1),5},'Paired Pulse'))
                            table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                            errordlg('CS Intensity and ISI are only Editable for the "Paired Pulse" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
                        else
                            switch CellEditData.Indices(2)
                                case ColCS
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=str2double(CellEditData.NewData);
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).cs=CellEditData.NewData;
                                case ColISI
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=str2double(CellEditData.NewData);
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).isi=CellEditData.NewData;
                            end
                            
                        end
                    case ColMotorThreshold
                        if ~(strcmp(table.Data{CellEditData.Indices(1),3},'%MT'))
                            table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                            errordlg('The selected Stimulation Intensity Units are %MSO, change it to %MT from its dropdown menu if you desire to update this value to a specific threshold','Warning | BEST Toolbox',opts);
                        else
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold=CellEditData.NewData;
                            
                        end
                end
                %Improvement Note :Requirement 96
                %                 obj.cm;
                %cb_pulse_update
                %cb_condition_addition
                %cb_condition_deletion
                %cb_stimulator_addition
                %cb_stimulator_deletion
                cb_pulse_update
                function cb_pulse_update
                    cd=[];
                    st=[];
                    condStr=[];
                    obj.pi.mm.tab.SelectedChild=str2double(table.Data{CellEditData.Indices(1),1});
                    
                    cd=['cd' num2str(table.Data{CellEditData.Indices(1),1})];
                    condStr=['cond' num2str(table.Data{CellEditData.Indices(1),1})];
                    obj.pi.mm.stim.(cd).slctd=AdditionInStimulatorNum;
                    st=['st' num2str(obj.pi.mm.stim.(cd).slctd)];
                    obj.pi.mm.stim.(cd).(st).pulse_count=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count;
                    axes(obj.pi.mm.cond.(cd).ax)
                    cla;
                    hold on;
                    contextMenu_condition=uicontextmenu(obj.fig.handle);
                    uimenu(contextMenu_condition,'label','Duplicate Condition','Callback',@cb_pr_mm_duplicateCondition);
                    uimenu(contextMenu_condition,'label','Delete Condition','Callback',@cb_pr_mm_deleteCondition);
                    obj.pi.mm.cond.(cd).ax.YLim=[-1 1];
                    obj.pi.mm.cond.(cd).ax.XLim=[0 5];
                    xticks(obj.pi.mm.cond.(cd).ax,[100 101]);
                    yticks(obj.pi.mm.cond.(cd).ax,-1:1:1)
                    obj.pi.mm.cond.(cd).ax.YTickLabel={'','MEP Search Window',''};
                    plot(0:0.01:10,rand(1,1001)*0.30-0.15,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag','empty'); % 12-Mar-2020 07:37:17
                    text(2.5,0+0.20,['Channel Name:[' char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).targetChannel) ']'],'VerticalAlignment','bottom','HorizontalAlignment','center','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','ButtonDownFcn',@obj.cb_cm_targetChannel) % 11-Mar-2020 14:49:00
                    obj.pi.mm.stim.(cd).no=0;
                    
                    %make stimulators
                    for istimulators=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr)))-1)
                        obj.pi.mm.stim.(cd).no=istimulators;
                        st=['st' num2str(obj.pi.mm.stim.(cd).no)];
                        axes(obj.pi.mm.cond.(cd).ax)
                        hold on;
                        obj.pi.mm.stim.(cd).(st).plt=plot([-45 45],[-1*obj.pi.mm.stim.(cd).no -1*obj.pi.mm.stim.(cd).no],'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@cb_stimulatorSelector); %line
                        %                     obj.pi.mm.stim.(cd).(st).pulse_count=0;
                        %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count=obj.pi.mm.stim.(cd).(st).pulse_count;
                        obj.pi.mm.cond.(cd).ax.YLim=[(-1-obj.pi.mm.stim.(cd).no) 1];
                        yticks(obj.pi.mm.cond.(cd).ax,[-1-obj.pi.mm.stim.(cd).no:1:1])
                        for i=1:obj.pi.mm.stim.(cd).no
                            yticklab{1,i}=cellstr(['Stimulator ' num2str(i)]);
                        end
                        yticklab=flip(horzcat(yticklab{1,:}));
                        obj.pi.mm.cond.(cd).ax.YTickLabel={'',char(yticklab),'MEP Search Window',''};
                        text(0,-1*obj.pi.mm.stim.(cd).no,char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_device),'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@obj.cb_cm_output_device)
                        for ipulses=1:obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count
                            
                            % 11-Mar-2020 18:13:21
                            obj.pi.mm.stim.(cd).slctd=istimulators;
                            obj.pi.mm.stim.(cd).(st).pulse_count=ipulses;
                            %                         obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count=obj.pi.mm.stim.(cd).(st).pulse_count;
                            
                            switch char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode)
                                case 'single_pulse'
                                    obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('single_pulse');
                                    %make the string here
                                    SinglePulseAnnotation=[];
                                    if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1)
                                        
                                        
                                        SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MSO'];
                                    else
                                        SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MT'];
                                    end
                                    %AAJ: idher ye banao jese oper hehehehehe
                                    %vala bnaya he pp aur train dono k lye
                                    text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,SinglePulseAnnotation,'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_sp_inputfig) % 11-Mar-2020 14:49:00
                                case 'paired_pulse'
                                    obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                                    % % %                                 text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{'TS:[?], CS:[?] %MSO', 'ISI:[?] ms'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                                    TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                                    CS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                                    ISI=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                                    if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                        UnitString='%MSO';
                                    elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                        UnitString='%MT';
                                    end
                                    text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{['TS:' TS ', CS:' CS ' ' UnitString], ['ISI:' ISI 'ms']},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                                    
                                case 'train'
                                    obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('train');
                                    %                                 obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{'Pulses:[?], f:[?] Hz', 'TS:[?] %MSO'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                                    TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                                    F=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                                    PULSES=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                                    if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                        UnitString='%MSO';
                                    elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                        UnitString='%MT';
                                    end
                                    obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{['Pulses:' PULSES ', f:' F 'Hz'], ['TS:' TS UnitString]},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                                    
                            end
                            
                            
                            % delete the previous plot
                            delete(obj.pi.mm.stim.(cd).(st).plt)
                            % make the x and y vector for new one
                            x=[];
                            y=[];
                            for i=1:obj.pi.mm.stim.(cd).(st).pulse_count
                                switch char(obj.pi.mm.stim.(cd).(st).pulse_types{1,i})
                                    case 'single_pulse'
                                        
                                        x{i}=([i i i+0.15 i+0.15]);
                                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                    case 'paired_pulse'
                                        
                                        x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40];
                                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                    case 'train'
                                        
                                        %                         x(i)=[i i i+0.20 i+0.20 i+0.30 i+0.30 i+0.50 i+0.50 i+0.60 i+0.60 i+0.80 i+0.80];
                                        x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40 i+0.50 i+0.50 i+0.65 i+0.65];
                                        %                         y{i}={[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd]};
                                        
                                        y{i}=-obj.pi.mm.stim.(cd).slctd+[0 0.4 0.4 0 0 0.4 0.4 0 0 0.4 0.4 0];
                                end
                            end
                            
                            x=[-45 cell2mat(x) 45];
                            y=[-obj.pi.mm.stim.(cd).slctd cell2mat(y) -obj.pi.mm.stim.(cd).slctd];
                            
                            obj.pi.mm.stim.(cd).(st).plt=plot(x,y,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).slctd),'ButtonDownFcn',@cb_stimulatorSelector); %line
                            
                            drawArrow = @(x,y) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0,'color','k' );
                            num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,ipulses})
                            obj.pi.mm.stim.(st).pulse_time=text(obj.pi.mm.stim.(cd).(st).pulse_count-1+0.5,-obj.pi.mm.stim.(cd).slctd-0.05,['t:' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,ipulses}) 'ms'],'VerticalAlignment','top','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_timing)
                            
                            obj.pi.mm.stim.(st).pulse_arrow1=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1 obj.pi.mm.stim.(cd).(st).pulse_count-1+1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                            obj.pi.mm.stim.(st).pulse_arrow2=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1+1 obj.pi.mm.stim.(cd).(st).pulse_count-1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                            
                            
                            if(obj.pi.mm.cond.(cd).ax.XLim(2)<obj.pi.mm.stim.(cd).(st).pulse_count+1)
                                obj.pi.mm.cond.(cd).ax.XLim(2)=obj.pi.mm.stim.(cd).(st).pulse_count+1;
                            end
                            
                        end
                        
                    end
                    function cb_stimulatorSelector(source,~)
                        if(isfield(obj.pi.mm,'stimulatorSelector'))
                            if(isvalid(obj.pi.mm.stimulatorSelector))
                                obj.pi.mm.stimulatorSelector.Color='k';
                            end
                        end
                        obj.pi.mm.stim.(cd).slctd=str2double(source.Tag);
                        source.Color='b';
                        obj.pi.mm.stimulatorSelector=source;
                    end
                    function cb_pr_mm_duplicateCondition(~,~)
                        
                        conditionIndex=length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll));
                        cond_duplicated_from=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                        cond_duplicated_to=['cond' num2str(conditionIndex+1)];
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_to)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_from);
                        obj.RefreshProtocol;
                    end
                    function cb_pr_mm_deleteCondition(~,~)
                        
                        
                        condsAll_fieldnames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll);
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=rmfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll,char(condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)));
                        condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)=[];
                        for deleteIndex_condition=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll)))
                            cond_resorted_afterdelete=['cond' num2str(deleteIndex_condition)];
                            condsAll_new.(cond_resorted_afterdelete)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(char(condsAll_fieldnames(deleteIndex_condition)));
                        end
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=condsAll_new;
                        obj.RefreshProtocol;
                    end
                end
                
                
                
                
                %AAJ: add a new uimenu in table for add a condition,
                %add a stimulator to this condition, delete a
                %condition, delete a stimulator
                
            end
        end
        function cb_cm_Nconditions(obj)
            
            obj.pi.mm.cond.TabNames=[];
            contextMenu_condition=uicontextmenu(obj.fig.handle);
            uimenu(contextMenu_condition,'label','Duplicate Condition','Callback',@cb_pr_mm_duplicateCondition);
            uimenu(contextMenu_condition,'label','Delete Condition','Callback',@cb_pr_mm_deleteCondition);
            for iconds=1:length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll))
                obj.pi.mm.cond.no=iconds;
                cd=['cd' num2str(obj.pi.mm.cond.no)];
                condStr=['cond' num2str(obj.pi.mm.cond.no)];
                obj.pi.mm.cond.(cd).ax_panel= uix.Panel( 'Parent',obj.pi.mm.tab,'uicontextmenu',contextMenu_condition);
                obj.pi.mm.cond.(cd).ax=axes('parent',obj.pi.mm.cond.(cd).ax_panel );
                box on; hold on;
                obj.pi.mm.cond.TabNames{1,obj.pi.mm.cond.no}=['Condition' num2str(obj.pi.mm.cond.no)];
                obj.pi.mm.tab.TabNames=obj.pi.mm.cond.TabNames;
                obj.pi.mm.tab.SelectedChild=1;
                obj.pi.mm.tab.TabSize=90;
                obj.pi.mm.tab.FontSize=12;
                obj.pi.mm.cond.(cd).ax.YLim=[-1 1];
                obj.pi.mm.cond.(cd).ax.XLim=[0 5];
                xticks(obj.pi.mm.cond.(cd).ax,[100 101]);
                yticks(obj.pi.mm.cond.(cd).ax,-1:1:1)
                obj.pi.mm.cond.(cd).ax.YTickLabel={'','MEP Search Window',''};
                plot(0:0.01:10,rand(1,1001)*0.30-0.15,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag','empty'); % 12-Mar-2020 07:37:17
                text(2.5,0+0.20,['Channel Name:[' char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).targetChannel) ']'],'VerticalAlignment','bottom','HorizontalAlignment','center','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','ButtonDownFcn',@obj.cb_cm_targetChannel) % 11-Mar-2020 14:49:00
                obj.pi.mm.stim.(cd).no=0;
                
                %                 make stimulators
                for istimulators=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr)))-6)
                    obj.pi.mm.stim.(cd).no=istimulators;
                    st=['st' num2str(obj.pi.mm.stim.(cd).no)];
                    axes(obj.pi.mm.cond.(cd).ax)
                    hold on;
                    obj.pi.mm.stim.(cd).(st).plt=plot([-45 45],[-1*obj.pi.mm.stim.(cd).no -1*obj.pi.mm.stim.(cd).no],'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@cb_stimulatorSelector); %line
                    
                    obj.pi.mm.cond.(cd).ax.YLim=[(-1-obj.pi.mm.stim.(cd).no) 1];
                    yticks(obj.pi.mm.cond.(cd).ax,[-1-obj.pi.mm.stim.(cd).no:1:1])
                    for i=1:obj.pi.mm.stim.(cd).no
                        yticklab{1,i}=cellstr(['Stimulator ' num2str(i)]);
                    end
                    yticklab=flip(horzcat(yticklab{1,:}));
                    obj.pi.mm.cond.(cd).ax.YTickLabel={'',char(yticklab),'MEP Search Window',''};
                    text(0,-1*obj.pi.mm.stim.(cd).no,char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_device),'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@obj.cb_cm_output_device)
                    for ipulses=1:obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count
                        
                        %                         11-Mar-2020 18:13:21
                        obj.pi.mm.stim.(cd).slctd=istimulators;
                        obj.pi.mm.stim.(cd).(st).pulse_count=ipulses;
                        
                        switch char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode)
                            case 'single_pulse'
                                obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('single_pulse');
                                %                                 make the string here
                                SinglePulseAnnotation=[];
                                if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1)
                                    
                                    
                                    SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MSO'];
                                else
                                    SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MT'];
                                end
                                %                                 AAJ: idher ye banao jese oper hehehehehe
                                %                                 vala bnaya he pp aur train dono k lye
                                text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,SinglePulseAnnotation,'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_sp_inputfig) % 11-Mar-2020 14:49:00
                            case 'paired_pulse'
                                obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                                % %                                 text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{'TS:[?], CS:[?] %MSO', 'ISI:[?] ms'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                                TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                                CS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                                ISI=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                                if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                    UnitString='%MSO';
                                elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                    UnitString='%MT';
                                end
                                text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{['TS:' TS ', CS:' CS ' ' UnitString], ['ISI:' ISI 'ms']},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                                
                            case 'train'
                                obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('train');
                                % %                                                                 obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{'Pulses:[?], f:[?] Hz', 'TS:[?] %MSO'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                                TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                                F=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                                PULSES=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                                if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                    UnitString='%MSO';
                                elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                    UnitString='%MT';
                                end
                                obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{['Pulses:' PULSES ', f:' F 'Hz'], ['TS:' TS UnitString]},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                                
                        end
                        
                        
                        %                         delete the previous plot
                        delete(obj.pi.mm.stim.(cd).(st).plt)
                        %                         make the x and y vector for new one
                        x=[];
                        y=[];
                        for i=1:obj.pi.mm.stim.(cd).(st).pulse_count
                            switch char(obj.pi.mm.stim.(cd).(st).pulse_types{1,i})
                                case 'single_pulse'
                                    x{i}=([i i i+0.15 i+0.15]);
                                    y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                case 'paired_pulse'
                                    x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40];
                                    y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                case 'train'
                                    x(i)=[i i i+0.20 i+0.20 i+0.30 i+0.30 i+0.50 i+0.50 i+0.60 i+0.60 i+0.80 i+0.80];
                                    x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40 i+0.50 i+0.50 i+0.65 i+0.65];
                                    y{i}={[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd]};
                                    
                                    y{i}=-obj.pi.mm.stim.(cd).slctd+[0 0.4 0.4 0 0 0.4 0.4 0 0 0.4 0.4 0];
                            end
                        end
                        
                        x=[-45 cell2mat(x) 45];
                        y=[-obj.pi.mm.stim.(cd).slctd cell2mat(y) -obj.pi.mm.stim.(cd).slctd];
                        
                        obj.pi.mm.stim.(cd).(st).plt=plot(x,y,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).slctd),'ButtonDownFcn',@cb_stimulatorSelector); %line
                        
                        drawArrow = @(x,y) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0,'color','k' );
                        num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,ipulses})
                        obj.pi.mm.stim.(st).pulse_time=text(obj.pi.mm.stim.(cd).(st).pulse_count-1+0.5,-obj.pi.mm.stim.(cd).slctd-0.05,['t:' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,ipulses}) 'ms'],'VerticalAlignment','top','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_timing)
                        
                        obj.pi.mm.stim.(st).pulse_arrow1=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1 obj.pi.mm.stim.(cd).(st).pulse_count-1+1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                        obj.pi.mm.stim.(st).pulse_arrow2=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1+1 obj.pi.mm.stim.(cd).(st).pulse_count-1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                        
                        
                        if(obj.pi.mm.cond.(cd).ax.XLim(2)<obj.pi.mm.stim.(cd).(st).pulse_count+1)
                            obj.pi.mm.cond.(cd).ax.XLim(2)=obj.pi.mm.stim.(cd).(st).pulse_count+1;
                        end
                        
                    end
                    
                end
                %                 make pulses
                
                
                
            end
            function cb_stimulatorSelector(source,~)
                if(isfield(obj.pi.mm,'stimulatorSelector'))
                    if(isvalid(obj.pi.mm.stimulatorSelector))
                        obj.pi.mm.stimulatorSelector.Color='k';
                    end
                end
                obj.pi.mm.stim.(cd).slctd=str2double(source.Tag);
                source.Color='b';
                obj.pi.mm.stimulatorSelector=source;
            end
            function cb_pr_mm_duplicateCondition(~,~)
                conditionIndex=length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll));
                cond_duplicated_from=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                cond_duplicated_to=['cond' num2str(conditionIndex+1)];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_to)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_from);
                obj.RefreshProtocol;
            end
            function cb_pr_mm_deleteCondition(~,~)
                
                condsAll_fieldnames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=rmfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll,char(condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)));
                condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)=[];
                for deleteIndex_condition=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll)))
                    cond_resorted_afterdelete=['cond' num2str(deleteIndex_condition)];
                    condsAll_new.(cond_resorted_afterdelete)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(char(condsAll_fieldnames(deleteIndex_condition)));
                end
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=condsAll_new;
                obj.RefreshProtocol;
            end
        end
        function cb_cm_conditions(obj)
            obj.pi.mm.cond.no=obj.pi.mm.cond.no+1;
            cd=['cd' num2str(obj.pi.mm.cond.no)];
            condStr=['cond' num2str(obj.pi.mm.cond.no)];
            contextMenu_condition=uicontextmenu(obj.fig.handle);
            uimenu(contextMenu_condition,'label','Duplicate Condition','Callback',@cb_pr_mm_duplicateCondition);
            uimenu(contextMenu_condition,'label','Delete Condition','Callback',@cb_pr_mm_deleteCondition);
            obj.pi.mm.cond.(cd).ax_panel= uix.Panel( 'Parent',obj.pi.mm.tab,'uicontextmenu',contextMenu_condition);
            obj.pi.mm.cond.(cd).ax=axes('parent',obj.pi.mm.cond.(cd).ax_panel );
            box on; hold on;
            obj.pi.mm.cond.TabNames{1,obj.pi.mm.cond.no}=['Condition' num2str(obj.pi.mm.cond.no)];
            obj.pi.mm.tab.TabNames=obj.pi.mm.cond.TabNames;
            obj.pi.mm.tab.SelectedChild=obj.pi.mm.cond.no;
            obj.pi.mm.tab.TabSize=90;
            obj.pi.mm.tab.FontSize=12;
            obj.pi.mm.cond.(cd).ax.YLim=[-1 1];
            obj.pi.mm.cond.(cd).ax.XLim=[0 5];
            xticks(obj.pi.mm.cond.(cd).ax,[100 101]);
            yticks(obj.pi.mm.cond.(cd).ax,[-1:1:1])
            obj.pi.mm.cond.(cd).ax.YTickLabel={'','MEP Search Window',''};
            plot(0:0.01:10,rand(1,1001)*0.30-0.15,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag','empty'); % 12-Mar-2020 07:37:17
            text(2.5,0+0.20,'Channel Name:[?]','VerticalAlignment','bottom','HorizontalAlignment','center','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','ButtonDownFcn',@obj.cb_cm_targetChannel) % 11-Mar-2020 14:49:00
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).targetChannel=cellstr('NaN');
            obj.pi.mm.stim.(cd).no=0;
            function cb_pr_mm_duplicateCondition(~,~)
                conditionIndex=length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll));
                cond_duplicated_from=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                cond_duplicated_to=['cond' num2str(conditionIndex+1)];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_to)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_from);
                obj.RefreshProtocol;
            end
            function cb_pr_mm_deleteCondition(~,~)
                condsAll_fieldnames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=rmfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll,char(condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)));
                condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)=[];
                for deleteIndex_condition=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll)))
                    cond_resorted_afterdelete=['cond' num2str(deleteIndex_condition)];
                    condsAll_new.(cond_resorted_afterdelete)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(char(condsAll_fieldnames(deleteIndex_condition)));
                end
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=condsAll_new;
                obj.RefreshProtocol;
            end
            obj.cb_cm_StimulationParametersTable;
            
            
        end
        function cb_cm_stim(obj)
            
            obj.pi.mm.tab.TabNames=obj.pi.mm.cond.TabNames;
            cd=['cd' num2str(obj.pi.mm.tab.SelectedChild)];
            condStr=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
            obj.pi.mm.stim.(cd).no=obj.pi.mm.stim.(cd).no+1;
            st=['st' num2str(obj.pi.mm.stim.(cd).no)];
            axes(obj.pi.mm.cond.(cd).ax)
            hold on;
            %             plot([-45 45],[1 1],'Color','k','parent',obj.pi.mm.ax);
            %             plot([-45 45],[0 0],'Color','k','parent',obj.pi.mm.ax);
            
            
            obj.pi.mm.stim.(cd).(st).plt=plot([-45 45],[-1*obj.pi.mm.stim.(cd).no -1*obj.pi.mm.stim.(cd).no],'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@cb_stimulatorSelector); %line
            %             obj.pi.mm.stim.(cd).(st).pulse_count=0;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count=0;
            obj.pi.mm.stim.(cd).(st).plt.Tag
            %             plot([-45 45],[-2-obj.pi.mm.stim.no -2-obj.pi.mm.stim.no],'Color','k','parent',obj.pi.mm.ax);
            obj.pi.mm.cond.(cd).ax.YLim=[(-1-obj.pi.mm.stim.(cd).no) 1];
            yticks(obj.pi.mm.cond.(cd).ax,[-1-obj.pi.mm.stim.(cd).no:1:1])
            for i=1:obj.pi.mm.stim.(cd).no
                yticklab{1,i}=cellstr(['Stimulator ' num2str(i)]);
            end
            yticklab=flip(horzcat(yticklab{1,:}));
            obj.pi.mm.cond.(cd).ax.YTickLabel={'',char(yticklab),'MEP Search Window',''};
            text(0,-1*obj.pi.mm.stim.(cd).no,'click to tag device','VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@obj.cb_cm_output_device)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_device=cellstr('Select');
            function cb_stimulatorSelector(source,~)
                if(isfield(obj.pi.mm,'stimulatorSelector'))
                    if(isvalid(obj.pi.mm.stimulatorSelector))
                        obj.pi.mm.stimulatorSelector.Color='k';
                    end
                end
                obj.pi.mm.stim.(cd).slctd=str2double(source.Tag);
                source.Color='b';
                obj.pi.mm.stimulatorSelector=source;
            end
            obj.cb_cm_StimulationParametersTable;
        end
        function cb_cm_pulse(obj,source,~)
            % 11-Mar-2020 18:13:21
            cd=['cd' num2str(obj.pi.mm.tab.SelectedChild)];
            condStr=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
            
            %             obj.pi.mm.stim.(cd).slctd=1 ;
            
            
            st=['st' num2str(obj.pi.mm.stim.(cd).slctd)];
            obj.pi.mm.stim.(cd).(st).pulse_count=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count+1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count=obj.pi.mm.stim.(cd).(st).pulse_count;
            
            switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count
                case 1
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode=source.Tag;
                    
                    switch source.Tag
                        case 'single_pulse'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('single_pulse');
                            text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,'       TS:[NaN] %MSO','VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_sp_inputfig) % 11-Mar-2020 14:49:00
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).threshold='';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode='single_pulse';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt={NaN};
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing={NaN};
                            
                        case 'paired_pulse'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                            text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{'TS:[NaN], CS:[NaN] %MSO', 'ISI:[NaN] ms'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).cs='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).isi='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).threshold='';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode='paired_pulse';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt={NaN,NaN,NaN};
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing={NaN};
                        case 'train'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('train');
                            obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{'Pulses:[NaN], f:[NaN] Hz', 'TS:[NaN] %MSO'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulsesNo='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).freq='NaN'; %only 1 SI is allowed as a standard model of generalization
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).threshold='';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode='train';
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt={NaN,NaN,NaN};
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing={NaN};
                    end
                otherwise
                    switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode
                        case 'single_pulse'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('single_pulse');
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing(1,obj.pi.mm.stim.(cd).(st).pulse_count)={NaN};
                            
                            if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                UnitString='%MSO';
                            elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                UnitString='%MT';
                            end
                            text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,['     TS: ' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) ' ' UnitString],'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_sp_inputfig) % 11-Mar-2020 14:49:00
                            
                            
                        case 'paired_pulse'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing(1,obj.pi.mm.stim.(cd).(st).pulse_count)={NaN};
                            TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                            CS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                            ISI=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                            if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                UnitString='%MSO';
                            elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                UnitString='%MT';
                            end
                            text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{['TS:' TS ', CS:' CS ' ' UnitString], ['ISI:' ISI 'ms']},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_pp_inputfig) % 11-Mar-2020 14:49:00
                        case 'train'
                            obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('train');
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing(1,obj.pi.mm.stim.(cd).(st).pulse_count)={NaN};
                            TS=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1});
                            F=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,2});
                            PULSES=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,3});
                            if obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==1
                                UnitString='%MSO';
                            elseif obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units==0
                                UnitString='%MT';
                            end
                            obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{['Pulses:' PULSES ', f:' F 'Hz'], ['TS:' TS UnitString]},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_train_inputfig); % 11-Mar-2020 14:49:00
                    end
                    
            end
            
            
            % delete the previous plot
            delete(obj.pi.mm.stim.(cd).(st).plt)
            % make the x and y vector for new one
            x=[];
            y=[];
            for i=1:obj.pi.mm.stim.(cd).(st).pulse_count
                switch char(obj.pi.mm.stim.(cd).(st).pulse_types{1,i})
                    case 'single_pulse'
                        x{i}=([i i i+0.15 i+0.15]);
                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                    case 'paired_pulse'
                        x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40];
                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                    case 'train'
                        %                         x(i)=[i i i+0.20 i+0.20 i+0.30 i+0.30 i+0.50 i+0.50 i+0.60 i+0.60 i+0.80 i+0.80];
                        x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40 i+0.50 i+0.50 i+0.65 i+0.65];
                        %                         y{i}={[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd+0.5 -obj.pi.mm.stim.(cd).slctd]};
                        
                        y{i}=-obj.pi.mm.stim.(cd).slctd+[0 0.4 0.4 0 0 0.4 0.4 0 0 0.4 0.4 0];
                end
            end
            
            x=[-45 cell2mat(x) 45];
            y=[-obj.pi.mm.stim.(cd).slctd cell2mat(y) -obj.pi.mm.stim.(cd).slctd];
            
            obj.pi.mm.stim.(cd).(st).plt=plot(x,y,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag',num2str(obj.pi.mm.stim.(cd).slctd),'ButtonDownFcn',@cb_stimulatorSelector); %line
            
            drawArrow = @(x,y) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0,'color','k' )
            obj.pi.mm.stim.(st).pulse_time=text(obj.pi.mm.stim.(cd).(st).pulse_count-1+0.5,-obj.pi.mm.stim.(cd).slctd-0.05,['t:' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,obj.pi.mm.stim.(cd).(st).pulse_count}) ' ms'],'VerticalAlignment','top','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_cm_timing)
            
            obj.pi.mm.stim.(st).pulse_arrow1=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1 obj.pi.mm.stim.(cd).(st).pulse_count-1+1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
            obj.pi.mm.stim.(st).pulse_arrow2=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1+1 obj.pi.mm.stim.(cd).(st).pulse_count-1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
            
            
            if(obj.pi.mm.cond.(cd).ax.XLim(2)<obj.pi.mm.stim.(cd).(st).pulse_count+1)
                obj.pi.mm.cond.(cd).ax.XLim(2)=obj.pi.mm.stim.(cd).(st).pulse_count+1;
            end
            
            
            function cb_stimulatorSelector(source,~)
                if(isvalid(obj.pi.mm.stimulatorSelector))
                    obj.pi.mm.stimulatorSelector.Color='k';
                end
                obj.pi.mm.stim.(cd).slctd=str2double(source.Tag);
                source.Color='b';
                obj.pi.mm.stimulatorSelector=source;
            end
            obj.cb_cm_StimulationParametersTable;
        end
        function cb_cm_output_device(obj,source,~)
            obj.hw.device_added1_listbox.string
            if(isempty(obj.hw.device_added2_listbox.string))
                errordlg('No Output Device (Stimulator) is configured before, visit Hardware Configuration section and configure a Hardware device before selecting one!', 'BEST Toolbox')
            else
                [indx,tf] = listdlg('PromptString',{'Select an Output Device'},'SelectionMode','single','ListString',obj.hw.device_added2_listbox.string);
                if(tf==1)
                    cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                    st=['st' num2str(source.Tag)];
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_device=obj.hw.device_added2_listbox.string(indx);
                    source.String=obj.hw.device_added2_listbox.string(indx);
                    obj.cb_cm_StimulationParametersTable;
                    
                end
                
            end
        end
        function cb_cm_timing(obj,source,~)
            prompt = {'Time (mili-seconds):'};
            dlgtitle = 'Insert Time | BEST Toolbox';
            dims = [1 60];
            definput = {'NaN'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            source.String=['t: ', char(answer), ' ms'];
            cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
            st=['st' num2str(source.UserData(2))];
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_timing(source.UserData(1))=num2cell(str2double(answer));
            obj.cb_cm_StimulationParametersTable;
            
        end
        function cb_cm_sp_inputfig(obj,source,~)
            if (source.UserData(2)==1)
                f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
                c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Threshold Variable:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                uicontrol( 'Style','edit','Parent', r1 ,'String','TS Intensity','FontSize',11,'Enable','off');
                set( r1, 'Widths', [210 200]);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Threshold Level (mV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                threshold_level=uicontrol( 'Style','edit','Parent', r1 ,'String','0.05','FontSize',11);
                set( r1, 'Widths', [210 200]);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Starting TS Intensity (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
                set( r1, 'Widths', [210 200]);
                
                uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
                
                set(c1, 'Heights', [25 25 25 25])
                f.Position(3)=430;
                f.Position(4)=150;
            else
                f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
                c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
                set( r1, 'Widths', [210 200]);
                
                r2=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                units_mso=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)cb_units_mso);
                units_mt=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MT','Callback',@(~,~)cb_units_mt);
                set( r2, 'Widths', [210 100 100]);
                
                r3=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r3,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                MotorThreshold=uicontrol( 'Style','edit','Parent', r3 ,'FontSize',11);
                uiextras.HBox('Parent',r3)
                ImportMotorThresholdFromProtocols=uicontrol( 'Style','popupmenu','Parent', r3 ,'FontSize',11,'String',{'Select'},'Callback',@setMotorThreshold);     % 11-Mar-2020 14:48:46                                                                  % 1297
                ImportMotorThresholdFromProtocols.String=getMotorThresholdProtocols;
                set( r3, 'Widths', [210 80 20 100]);
                
                
                uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
                
                set(c1, 'Heights', [25 25 25 25])
                f.Position(3)=430;
                f.Position(4)=150;
            end
            function cb_ok
                source.String=['TS:' si.String ' %MSO']; % 11-Mar-2020 14:48:28
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                st=['st' num2str(source.UserData(2))];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si=si.String; %only 1 SI is allowed as a standard model of generalization
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                try
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold=MotorThreshold.String;
                catch
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold='';
                end
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_mode='single_pulse';
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_pckt={str2double(si.String)};
                if (source.UserData(2)==1)
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold_level=str2double(threshold_level.String);
                end
                obj.cb_cm_StimulationParametersTable;
                close(f)
            end
            function cb_units_mso
                if(units_mso.Value==1)
                    units_mt.Value=0;
                end
            end
            function cb_units_mt
                if(units_mt.Value==1)
                    units_mso.Value=0;
                end
            end
            function MotorThresholdProtocols=getMotorThresholdProtocols
                mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
                MotorThresholdProtocols=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
                if isempty(MotorThresholdProtocols)
                    MotorThresholdProtocols={'Select'};
                end
            end
            function setMotorThreshold(Thissource,~)
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                st=['st' num2str(source.UserData(2))];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).ImportMotorThresholdFromProtocol=regexprep((Thissource.String{Thissource.Value}),' ','_');
                ImportMotorThresholdFromProtocol=regexprep((Thissource.String{Thissource.Value}),' ','_');
                if ~strcmpi(Thissource.String,'Select')
                    TargetConditions=numel(fieldnames(obj.par.(obj.info.event.current_session).(ImportMotorThresholdFromProtocol).condsAll));
                    if TargetConditions>1
                        for condtn=1:TargetConditions
                            cdd=['cond' num2str(condtn)];
                            TargetChannelforThreshold=obj.par.(obj.info.event.current_session).(ImportMotorThresholdFromProtocol).condsAll.(cdd).targetChannel{1};
                            AllConditions{condtn}=TargetChannelforThreshold;
                        end
                        [indx,tf] = listdlg('PromptString',{'Multiple Target Channels were found in your selection','Select one Target Channel.',''},'SelectionMode','single','ListString',AllConditions);
                        if tf==1
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).ImportMotorThresholdFromChannel=AllConditions{indx};
                            ImportMotorThresholdFromChannel=AllConditions{indx};
                        elseif tf==0
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).ImportMotorThresholdFromChannel=AllConditions{1};
                            ImportMotorThresholdFromChannel=AllConditions{1};
                        end
                    else
                        ImportMotorThresholdFromChannel=obj.par.(obj.info.event.current_session).(ImportMotorThresholdFromProtocol).condsAll.cond1.targetChannel{1};
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).ImportMotorThresholdFromChannel=ImportMotorThresholdFromChannel;
                    end
                    try
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold=obj.bst.sessions.(obj.info.event.current_session).(ImportMotorThresholdFromProtocol).results.(ImportMotorThresholdFromChannel).MotorThreshold;
                    catch
                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold='Not Found';
                    end
                    MotorThreshold.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold;
                end
            end
        end
        function cb_cm_pp_inputfig(obj,source,~)
            if (source.UserData(2)==1)
                f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
                c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Threshold Variable:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                uicontrol( 'Style','edit','Parent', r1 ,'String','TS Intensity','FontSize',11,'Enable','off');
                set( r1, 'Widths', [250 200]);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Threshold Level (mV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                uicontrol( 'Style','edit','Parent', r1 ,'String','0.05','FontSize',11);
                set( r1, 'Widths', [250 200]);
                
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Starting TS Intensity:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
                set( r1, 'Widths', [250 200]);
                
                r2a=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2a,'String','Condition Stimulus (CS) Intensity:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                cs=uicontrol( 'Style','edit','Parent', r2a ,'String','NaN','FontSize',11);
                set( r2a, 'Widths', [250 200]);
                
                r2b=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2b,'String','Inter Stimulus Interval (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                isi=uicontrol( 'Style','edit','Parent', r2b ,'String','NaN','FontSize',11);
                set( r2b, 'Widths', [250 200]);
                
                uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
                
                set(c1, 'Heights', [25 25 25 25 25 25])
                f.Position(3)=480;
                f.Position(4)=220;
            else
                f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
                c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
                r1=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r1,'String','Test Stimulus Intensity (TS):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
                set( r1, 'Widths', [250 200]);
                
                r2a=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2a,'String','Condition Stimulus Intensity (CS):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                cs=uicontrol( 'Style','edit','Parent', r2a ,'String','NaN','FontSize',11);
                set( r2a, 'Widths', [250 200]);
                
                r2b=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2b,'String','Inter Stimulus Interval (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                isi=uicontrol( 'Style','edit','Parent', r2b ,'String','NaN','FontSize',11);
                set( r2b, 'Widths', [250 200]);
                
                r2=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r2,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                units_mso=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)cb_units_mso);
                units_mt=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MT','Callback',@(~,~)cb_units_mt);
                set( r2, 'Widths', [250 100 100]);
                
                r3=uix.HBox('parent',c1);
                uicontrol( 'Style','text','Parent', r3,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                threshold=uicontrol( 'Style','edit','Parent', r3 ,'FontSize',11);
                mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
                mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
                mt_btn_listbox_str=['Select' mt_btn_listbox_str];
                uiextras.HBox('Parent',r3)
                th_dropdown=uicontrol( 'Style','popupmenu','Parent', r3 ,'FontSize',11,'String',mt_btn_listbox_str);     % 11-Mar-2020 14:48:46                                                                  % 1297
                set( r3, 'Widths', [250 80 20 100]);
                
                
                uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
                
                set(c1, 'Heights', [25 25 25 25 25 25])
                f.Position(3)=480;
                f.Position(4)=220;
            end
            function cb_ok
                
                % source.String={['TS:' char(si.String) ']'];['CS:[' char(cs.String) '] %MSO'];['ISI:[' char(isi.String) '] ms']} % 11-Mar-2020 14:48:28
                
                
                source.String={['TS:' char(si.String)];['CS:' char(cs.String) ' %MSO'];['ISI:' char(isi.String) ' ms']} % 11-Mar-2020 14:48:28
                
                %                 source.String=['TS:[' si.String '] %MSO']; % 11-Mar-2020 14:48:28
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                st=['st' num2str(source.UserData(2))];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si=si.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).cs=cs.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).isi=isi.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_units=units_mso.Value; %if 1 then its mso if 0 then its threshold
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold=threshold.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_mode='paired_pulse';
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_pckt={str2double(si.String),str2double(cs.String),str2double(isi.String)};
                obj.cb_cm_StimulationParametersTable;
                
                close(f)
            end
            function cb_units_mso
                if(units_mso.Value==1)
                    units_mt.Value=0;
                end
            end
            function cb_units_mt
                if(units_mt.Value==1)
                    units_mso.Value=0;
                end
            end
        end
        function cb_cm_train_inputfig(obj,source,~)
            f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
            c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
            r1=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r1,'String','Stimulation Intensities (TS):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
            set( r1, 'Widths', [250 200]);
            
            r2a=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r2a,'String','Pulse Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            freq=uicontrol( 'Style','edit','Parent', r2a ,'String','NaN','FontSize',11);
            set( r2a, 'Widths', [250 200]);
            
            r2b=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r2b,'String','No of Pulses:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            pulsesNo=uicontrol( 'Style','edit','Parent', r2b ,'String','NaN','FontSize',11);
            set( r2b, 'Widths', [250 200]);
            
            r2=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r2,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            units_mso=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)cb_units_mso);
            units_mt=uicontrol( 'Style','radiobutton','Parent', r2 ,'FontSize',11,'String','%MT','Callback',@(~,~)cb_units_mt);
            set( r2, 'Widths', [250 100 100]);
            
            r3=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r3,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            threshold=uicontrol( 'Style','edit','Parent', r3 ,'FontSize',11);
            mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
            mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
            mt_btn_listbox_str=['Select' mt_btn_listbox_str];
            uiextras.HBox('Parent',r3)
            th_dropdown=uicontrol( 'Style','popupmenu','Parent', r3 ,'FontSize',11,'String',mt_btn_listbox_str);     % 11-Mar-2020 14:48:46                                                                  % 1297
            set( r3, 'Widths', [250 80 20 100]);
            
            
            uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
            
            set(c1, 'Heights', [25 25 25 25 25 25])
            f.Position(3)=480;
            f.Position(4)=220;
            function cb_ok
                
                
                
                source.String={['Pulses:' char(pulsesNo.String) ', f:' char(freq.String) ' Hz'];['TS:' char(si.String) ' %MSO']}; % 11-Mar-2020 14:48:28
                
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                st=['st' num2str(source.UserData(2))];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si=si.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).freq=freq.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).pulsesNo=pulsesNo.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_units=units_mso.Value; %if 1 then its mso if 0 then its threshold
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold=threshold.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_mode='train';
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_pckt={str2double(si.String),str2double(freq.String),str2double(pulsesNo.String)}
                obj.cb_cm_StimulationParametersTable;
                
                close(f)
            end
            function cb_units_mso
                if(units_mso.Value==1)
                    units_mt.Value=0;
                end
            end
            function cb_units_mt
                if(units_mt.Value==1)
                    units_mso.Value=0;
                end
            end
            
        end
        function cb_cm_targetChannel(obj,source,~)
            f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
            c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
            
            
            
            r1=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r1,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            targetChannels=uicontrol( 'Style','edit','Parent', r1 ,'FontSize',11);
            set( r1, 'Widths', [250 200]);
            
            
            uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
            
            set(c1, 'Heights', [25 25])
            f.Position(3)=480;
            f.Position(4)=90;
            function cb_ok
                source.String=['Channel Name:' targetChannels.String]; % 11-Mar-2020 14:48:28
                
                %                 source.String=['Channels:' targetChannels.String ' ' displayChannels.String , 'Pre/Post Display Period:' prestim_scope_plt.String '-' poststim_scope_plt.String 'ms']; % 11-Mar-2020 14:48:28
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                % 12-Mar-2020 08:53:28
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.input_device=inputDevice.String(inputDevice.Value);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).targetChannel=eval(targetChannels.String);
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.displayChannels=eval(displayChannels.String);
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.mepOnset=mepOnset.String;
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.mepOffset=mepOffset.Value; %if 1 then its mso if 0 then its threshold
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.prestim_scope_plt=prestim_scope_plt.String;
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.poststim_scope_plt=poststim_scope_plt.String;
                %                 obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(cd).inputDevice.measure_str='MEP Measurement';
                obj.cb_cm_StimulationParametersTable;
                
                close(f)
            end
            
        end
        %% Helper Function
       function RefreshProtocol(obj)
           switch obj.info.event.current_measure
                case 'MEP Measurement'
                    obj.pi_mep;
                    obj.func_load_mep_par;
                case 'MEP Hotspot Search'
                    obj.pi_hotspot;
                    obj.func_load_hotspot_par;
                case 'MEP Motor Threshold Hunting'
                    %                     obj.pi_mt_ptc;
                    %                     obj.func_load_mt_ptc_par;
                    obj.pr_mth;
                    obj.func_load_mth_par;
                case 'TMS fMRI'
                    obj.pi_tmsfmri;
                    obj.func_load_tmsfmri_par;
                case 'MEP Dose Response Curve'
                    obj.pi_drc;
                    obj.func_load_mepdrc_par;
                case 'Sensory Threshold Hunting'
                    obj.pr_psychmth;
                    obj.func_load_psychmth_par;
                case 'rTMS Intervention'
                    obj.pi_rtms;
                    obj.func_load_rtms_par;
                case 'rsEEG Measurement'
                    obj.pi_rseeg;
                    obj.func_load_rseeg_par;
                case 'ERP Measurement'
                    obj.pi_erp;
                    obj.func_load_erp_par;
                case 'TEP Hotspot Search'
                    obj.pi_tephs;
                    obj.func_load_tephs_par;
                case 'TEP Measurement'
                    obj.pi_tep;
                    obj.func_load_tep_par;
            end
       end

    end
end