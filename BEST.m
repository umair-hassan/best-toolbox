classdef BEST < handle
    properties
        par
        bst
        info
        data
        save_buffer
        pr
        pi
    end
    
    properties (Hidden)
        pmd %panel_measurement_designer
        %         pi  %panel_inputs
        %         pr %panel_results
        hw
        var
        grid % bottom most 3 panels
        panel
        pulse
        fig
        menu
        icons
        %         save_buffer
    end
    
    
    methods
        %% BESTq-
        function obj=BEST()
%             close all
            obj.create_gui;
        end
        function create_gui(obj)
            obj.create_best_obj;
            obj.create_figure;
            obj.create_menu;
            obj.create_main_panel;
            obj.create_inputs_panel;
            obj.create_results_panel;
            obj.create_hwcfg_panel;
            %               obj.pi_ioc
            %             obj.results_panel;
            % obj.pr.axesno=6;
            % obj.resultsPanel
            
            
            
        end
        function create_best_obj(obj)
            obj.bst= best_toolbox (obj);
            %              obj.bst= best_toolbox_gui_version_inprogress_testinlab_2910_sim (obj);
        end
        function create_figure(obj)
            obj.fig.handle = figure('Tag','umi1','ToolBar','none','MenuBar','none','Name','BEST Toolbox','NumberTitle','off');
            
            obj.info.session_no=0;
            obj.info.measurement_no=0;
            obj.info.event.current_session={};
            obj.info.event.current_measure={};
            obj.info.session_matrix={};
            
            % set(fig, 'Position', get(0, 'Screensize'));
            set(obj.fig.handle,'Units','normalized', 'Position', [0 0 0.8 0.8]);
            
            
            obj.pr.mep.axes1=axes;
            obj.pr.hotspot.axes1=axes;
            obj.pr.mt.axes_mep=axes;
            obj.pr.mt.axes_mtplot=axes;
            obj.pr.ioc.axes_mep=axes;
            obj.pr.ioc.axes_scatplot=axes;
            obj.pr.ioc.axes_fitplot=axes;
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
        function create_menu(obj)
            
            obj.fig.vbox=uix.VBox( 'Parent', obj.fig.handle, 'Spacing', 5, 'Padding', 5  );
            obj.fig.menu=uix.Panel( 'Parent',obj.fig.vbox, 'Padding', 1);
            menu_hbox=uix.HBox('Parent',obj.fig.menu,'Spacing', 5  );
            obj.menu.load.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Load','FontWeight','Bold','Callback',@(~,~)obj.cb_menu_load );
            obj.menu.save.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Save','FontWeight','Bold','Callback',@(~,~)obj.cb_menu_save);
            %             obj.menu.subjdata.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Subject Data','FontWeight','Bold' );
            obj.menu.md.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Measurement Designer','FontWeight','Bold' ,'Callback', @(~,~)obj.cb_menu_md);
            obj.menu.ip.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Stimulation Parameters','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_ip );
            obj.menu.rp.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Results Panel','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_rp );
            obj.menu.hwcfg.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Hardware Configuration','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_hwcfg );
            obj.menu.settings.btn=uicontrol( 'Parent', menu_hbox ,'Style','PushButton','String','Toolbox Settings','FontWeight','Bold','Callback', @(~,~)obj.cb_menu_rp );
            
            uiextras.HBox( 'Parent', menu_hbox,'Spacing', 5, 'Padding', 5 );
            set(menu_hbox,'Widths',[-1 -1 -2 -1.8 -1.5 -2 -2 -6]);
            
            
            obj.info.menu.md=0;
            obj.info.menu.ip=0;
            obj.info.menu.rp=0;
            obj.info.menu.hwcfg=0;
            
            
        end
        function create_main_panel(obj)
            obj.fig.main = uix.GridFlex( 'Parent', obj.fig.vbox, 'Spacing', 5 );
            set(obj.fig.vbox,'Heights',[-1 -25]);
            p_measurement_designer = uix.Panel( 'Parent', obj.fig.main, 'Padding', 5,  'Units','normalized','BorderType','none');
            obj.pmd.panel = uix.Panel( 'Parent', p_measurement_designer, 'Title', 'Experiment Designer', 'Padding', 5,'FontSize',14 ,'Units','normalized','FontWeight','bold','TitlePosition','centertop');
            pmd_vbox = uix.VBox( 'Parent', obj.pmd.panel, 'Spacing', 5, 'Padding', 5  );
            
            % experiment title: first horizontal row in measurement designer panel
            pmd_hbox_exp_title = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_exp_title,'String','Experiment Title:','FontSize',11,'HorizontalAlignment','left','Units','normalized' );
            obj.pmd.exp_title.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_exp_title ,'FontSize',11,'Callback',@(~,~)obj.cb_pmd_exp_title_editfield);
            obj.pmd.exp_title.btn=uicontrol( 'Parent', pmd_hbox_exp_title ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir );
            set( pmd_hbox_exp_title, 'Widths', [120 -0.7 -0.09]);
            
            % subject code: second horizontal row on first panel
            pmd_hbox_sub_code = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_sub_code,'String','Subject Code:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pmd.sub_code.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_sub_code ,'FontSize',11,'Callback',@(~,~)obj.cb_pmd_sub_code_editfield);
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
            uicontrol( 'Style','text','Parent', pmd_hbox_slct_mes,'String','Select Measure:','FontSize',11,'HorizontalAlignment','left' ,'Units','normalized');
            obj.pmd.select_measure.string={'MEP Measurement','MEP IOC_new','Multimodal Experiment','MEP Hotspot Search','MEP Motor Threshold Hunting','MEP Dose Response Curve_sp','EEG triggered Stimulation','TMS fMRI','TEP Measurement','ERP Measurement','rs EEG Analysis','rTMS Interventions'};
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
            mus2 = uimenu(m_sessions,'label','Paste Above','Callback',@(~,~)obj.cb_pmd_lb_sessions_pasteup);
            mus3 = uimenu(m_sessions,'label','Paste Below','Callback',@(~,~)obj.cb_pmd_lb_sessions_pastedown);
            mus4 = uimenu(m_sessions,'label','Delete','Callback',@(~,~)obj.cb_pmd_lb_sessions_del);
            mus5 = uimenu(m_sessions,'label','Move Up','Callback',@(~,~)obj.cb_pmd_lb_sessions_moveup);
            mus5 = uimenu(m_sessions,'label','Move Down','Callback',@(~,~)obj.cb_pmd_lb_sessions_movedown);
            
            obj.pmd.lb_sessions.listbox=uicontrol( 'Style','listbox','Parent', pmd_vbox ,'KeyPressFcn',@(~,~)obj.cb_pmd_lb_session_keypressfcn,'FontSize',11,'String',obj.pmd.lb_sessions.string,'uicontextmenu',m_sessions,'Callback',@(~,~)obj.cb_session_listbox);
            
            %empty 8th horizontal row on first panel
            uicontrol( 'Style','text','Parent', pmd_vbox,'String','Protocol','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            %measurement listbox: 9th horizontal row on first panel
            %             measure_lb2={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','Dose-Response Curve (MEP-sp)','Dose-Response Curve (MEP-pp)','EEG triggered TMS','MR triggered TMS','TEP Measurement'};
            obj.pmd.lb_measures.string={};
            m=uicontextmenu(obj.fig.handle);
            mu1 = uimenu(m,'label','Copy','Callback',@(~,~)obj.cb_pmd_lb_measures_copy);
            mu2 = uimenu(m,'label','Paste Above','Callback',@(~,~)obj.cb_pmd_lb_measures_pasteup);
            mu3 = uimenu(m,'label','Paste Below','Callback',@(~,~)obj.cb_pmd_lb_measures_pastedown);
            mu4 = uimenu(m,'label','Delete','Callback',@(~,~)obj.cb_pmd_lb_measures_del);
            mu5 = uimenu(m,'label','Move Up','Callback',@(~,~)obj.cb_pmd_lb_measures_moveup);
            mu6 = uimenu(m,'label','Move Down','Callback',@(~,~)obj.cb_pmd_lb_measures_movedown);
            obj.pmd.lb_measure_menu_loadresults=uimenu(m,'label','Load Results','Callback',@(~,~)obj.cb_pmd_lb_measure_menu_loadresult);
            
            obj.pmd.lb_measures.listbox=uicontrol( 'Style','listbox','Parent', pmd_vbox ,'KeyPressFcn',@(~,~)obj.cb_pmd_lb_measure_keypressfcn,'FontSize',11,'String',obj.pmd.lb_measures.string,'uicontextmenu',m,'Callback',@(~,~)obj.cb_measure_listbox);
            m=uicontextmenu(obj.fig.handle);
            
            
            set( pmd_vbox, 'Heights', [-0.05 -0.05 -0.05 -0.05 0 -0.04 -0.11 -0.04 -0.63]);
            
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
                obj.info.session_copied=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value)
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
                obj.info.session_matrix_copybuffer(1,obj.info.session_copy_id)=obj.info.session_copied
                obj.info.session_copied=obj.info.session_copied{1}
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
                    obj.enable_default_fields;
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
                obj.info.session_matrix_copybuffer(1,obj.info.session_copy_id)=obj.info.session_copied
                obj.info.session_copied=obj.info.session_copied{1}
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
                    obj.enable_default_fields;
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
                obj.enable_default_fields;
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
                obj.enable_default_fields;
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
                    
                    obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.(obj.info.event.current_session).info.measurement_str
                    
                    
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
                    
                    obj.data.(obj.info.event.current_session).info.measurement_str_original=obj.data.(obj.info.event.current_session).info.measurement_str
                    
                    
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
            if(numel(obj.pmd.lb_measures.listbox.String)==0)
                return
            else
                if(strcmp(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable,'off'))
                    delete(obj.pr.mep.axes1)
                    delete(obj.pr.hotspot.axes1)
                    delete(obj.pr.mt.axes_mep)
                    delete(obj.pr.mt.axes_mtplot)
                    delete(obj.pr.ioc.axes_mep)
                    delete(obj.pr.ioc.axes_scatplot)
                    delete(obj.pr.ioc.axes_fitplot)
                    switch obj.info.event.current_measure
                        case 'MEP Measurement'
                            obj.pr_mep;
                            obj.bst.inputs.current_session=obj.info.event.current_session;
                            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
                            obj.bst.best_mep_posthoc();
                        case 'MEP Hotspot Search'
                            obj.pr_hotspot
                            obj.bst.inputs.current_session=obj.info.event.current_session;
                            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
                            obj.bst.best_hotspot_posthoc();
                        case 'MEP Motor Threshold Hunting'
                            obj.pr_mt
                            obj.bst.inputs.current_session=obj.info.event.current_session;
                            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
                            obj.bst.best_mt_posthoc();
                        case 'MEP Dose Response Curve_sp'
                            obj.pr_ioc
                            obj.bst.inputs.current_session=obj.info.event.current_session;
                            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
                            obj.bst.best_ioc_posthoc();
                    end
                else
                    errordlg('No results exist for this measurement, Please collect the data if you wish to see the results for this particular measure.','BEST Toolbox');
                    return
                end
            end
        end
        %% input panels
        function create_inputs_panel(obj)
            obj.pi.empty_panel = uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            obj.pi.no_measure_slctd_panel.handle=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Stimulation Parameters','FontWeight','Bold','TitlePosition','centertop' );
            obj.pi.no_measure_slctd_panel.vbox = uix.VBox( 'Parent', obj.pi.no_measure_slctd_panel.handle, 'Spacing', 5, 'Padding', 5  );
            uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox)
            uicontrol( 'Parent', obj.pi.no_measure_slctd_panel.vbox,'Style','text','String','No Protocol is selected','FontSize',11,'HorizontalAlignment','center','Units','normalized' );
            uiextras.HBox( 'Parent', obj.pi.no_measure_slctd_panel.vbox);
            %           obj.panel.st=set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
            set(obj.pi.no_measure_slctd_panel.vbox,'Heights',[-2 -0.5 -2])
        end
        
        %% results panel
        function resultsPanel(obj)
            % IMP1: ye jo case 1 se le ker 6 tak jo me ne bar bar repeat ki
            % he linen ye for loop ban sakta he aur asani se simplfy kia ja
            % sakta he aur ye bat bhi k konsa function apply kerna matlab
            % mep ya threshold ye waghera bhi inteliggently decide kia ja
            % sakta he magr ye bad me kia ja sakta he filhal move on
            %             obj.pr.axesno=3;
            total_axesno=obj.pr.axesno;
            obj.pr_analytics;
            if(obj.pr.axesno>1)
                obj.pr.grid=uiextras.GridFlex('Parent',obj.pr.row4, 'Spacing', 1 );
            end
            
            for i=1:total_axesno
                obj.pr.axesno=i;
                obj.pr.ax_measures{1,i}
                switch char(obj.pr.ax_measures{1,i})
                    case 'MEP_Measurement'
                        obj.pr_mep;
                    case 'MEP Scatter Plot'
                        disp enteredSCATTTTTTTTPLOT
                        obj.pr_scat_plot;
                    case 'MEP IOC Fit'
                        obj.pr_fit_plot;
                    case 'Motor Threshold Hunting'
                        obj.pr_threshold_trace_plot;
                    case 'Phase Histogram'
                end
                
            end
            switch obj.pr.axesno
                case 1
                    %                     obj.pr.grid.ColumnSizes=[-1];
                case 2
                    obj.pr.grid.ColumnSizes=[-1 -1];
                case 3
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                case 4
                    obj.pr.grid.ColumnSizes=[-1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 5
                    uiextras.HBox( 'Parent', obj.pr.grid)
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
                case 6
                    obj.pr.grid.ColumnSizes=[-1 -1 -1];
                    obj.pr.grid.RowSizes=[-1 -1];
            end
        end
        function pr_analytics(obj)
            %FUTURE: each of dusplay module (MEP, Thresholding, IOC, PP
            %IOC, etc will have their own analytics panel, for now
            %generalized is ok
            % this below code will be then suitable for MEP , Hotspot, IOC
            % single pulse measurements
            
            
            %iska axis no se koi tauliq nahi hoga q k ye generalized hogi
            %har module ki, har module k lye mukthali fields hongi jo k is
            %module k update kerny valy function ko he sirf pata hongi
            
            obj.pr.panel_1= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.pr.vb=uix.VBox( 'Parent', obj.pr.panel_1, 'Spacing', 5, 'Padding', 5  );
            
            row1=uix.HBox( 'Parent', obj.pr.vb, 'Spacing', 5, 'Padding', 0  );
            uiextras.HBox( 'Parent', row1)
            uiextras.HBox( 'Parent', row1)
            obj.pr.total_trials_label=uicontrol( 'Style','text','Parent', row1,'String','Total Trials','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            obj.pr.trial_no_label=uicontrol( 'Style','text','Parent', row1,'String','Trial No.','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            if(strcmp(obj.bst.inputs.stim_mode,'MSO'))
                obj.pr.stim_intensity_label=uicontrol( 'Style','text','Parent', row1,'String','Intensity (%MSO)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            else
                obj.pr.stim_intensity_label=uicontrol( 'Style','text','Parent', row1,'String','Stim Intensity (%MT)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            end
            obj.pr.iti_label=uicontrol( 'Style','text','Parent', row1,'String','ITI (s)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', row1)
            set(row1,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            row2= uix.HBox( 'Parent', obj.pr.vb, 'Spacing', 5, 'Padding', 0  );
            uiextras.HBox( 'Parent', row2)
            obj.pr.current_trial_label=uicontrol( 'Style','text','Parent', row2,'String','Current Trial','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_totaltrial_no=uicontrol( 'Style','edit','Parent', row2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_trial=uicontrol( 'Style','edit','Parent', row2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_si=uicontrol( 'Style','edit','Parent', row2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.current_iti=uicontrol( 'Style','edit','Parent', row2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', row2)
            set(row2,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            row3= uix.HBox( 'Parent',obj.pr.vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', row3)
            obj.pr.next_trial_label=uicontrol( 'Style','text','Parent', row3,'String','Next Trial','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.next_totaltrial_no=uicontrol( 'Style','edit','Parent', row3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.next_trial=uicontrol( 'Style','edit','Parent', row3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.next_si=uicontrol( 'Style','edit','Parent', row3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.next_iti=uicontrol( 'Style','edit','Parent', row3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', row3)
            set(row3,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            
            obj.pr.row4= uix.HBox( 'Parent', obj.pr.vb, 'Spacing', 5, 'Padding', 5  );
            
            
            set(obj.pr.vb,'Heights',[30 30 30 -9])
        end
        function pr_mep(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            obj.pr.ax_no
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','Y-axis Max limit Increase','Callback',@obj.ymaxInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Max limit Decrease','Callback',@obj.ymaxDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Increase','Callback',@obj.yminInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Decrease','Callback',@obj.yminDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Insert Y-axis limits mannualy','Callback',@obj.ylims,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Change Font Size','Callback',@(~,~)obj.fontSize,'Tag',obj.pr.ax_no);
            
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'MEP Measurement','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
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
        function pr_scat_plot(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'MEP Scatter Plot','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.clab.(obj.pr.ax_no), 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.ax.(obj.pr.ax_no)=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
        end
        function pr_fit_plot(obj)
            obj.pr.ax_no=['ax' num2str(obj.pr.axesno)];
            obj.pr.ax_no
            ui_menu=uicontextmenu(obj.fig.handle);
            uimenu(ui_menu,'label','Y-axis Max limit Increase','Callback',@obj.ymaxInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Max limit Decrease','Callback',@obj.ymaxDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Increase','Callback',@obj.yminInc,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Y-axis Min limit Decrease','Callback',@obj.yminDec,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Insert Y-axis limits mannualy','Callback',@obj.ylims,'Tag',obj.pr.ax_no);
            uimenu(ui_menu,'label','Change Font Size','Callback',@(~,~)obj.fontSize,'Tag',obj.pr.ax_no);
            
            obj.pr.clab.(obj.pr.ax_no)=uix.Panel( 'Parent', obj.pr.grid, 'Padding', 5 ,'Units','normalized','Title', 'Input Output Curve','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.clab.(obj.pr.ax_no), 'Spacing', 5, 'Padding', 1  );
            
            mep1_row1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            mep1_row1_vb=uix.VBox( 'Parent',  mep1_row1, 'Spacing', 5, 'Padding', 1  );
            mep1_r1 = uix.HBox( 'Parent', mep1_row1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.inflectionPoint_label.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r1,'String','Inflection Point','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.ip_mso.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.ip_mso_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r1,'String','(%MSO))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.ip_muv.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.ip_muv_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r1,'String','(\muV))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 60 70 60 -0.3])
            
            
            mep1_r2a = uix.HBox( 'Parent',  mep1_row1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r2a)
            obj.pr.pt_label.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2a,'String','Plateau','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.pt_mso.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r2a,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.pt_mso_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2a,'String','(%MSO))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.pt_muv.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r2a,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.pt_muv_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2a,'String','(\muV))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r2a)
            set(mep1_r2a,'Widths',[-0.3 130 70 60 70 60 -0.3])
            
            mep1_r2b = uix.HBox( 'Parent', mep1_row1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r2b)
            obj.pr.th_label.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2b,'String','Threshold','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.th_mso.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r2b,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.th_mso_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2b,'String','(%MSO))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.th_muv.(obj.pr.ax_no)=uicontrol( 'Style','edit','Parent', mep1_r2b,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.th_muv_units.(obj.pr.ax_no)=uicontrol( 'Style','text','Parent', mep1_r2b,'String','(\muV))','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r2b)
            set(mep1_r2b,'Widths',[-0.3 130 70 60 70 60 -0.3])
            
            set(mep1_row1_vb,'Heights',[-1 -1 -1])
            
            
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.ax.(obj.pr.ax_no)=axes( 'Parent',  mep1_r2,'Units','normalized','uicontextmenu',ui_menu);
            
            
            
            set(mep1_vb,'Heights',[65 -10])
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
            current_ylim=obj.pr.ax.(selectedAxes).YLim(1)
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
        function fontSize(obj,source,~)
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
        function pr_phasehisto(obj)
        end
        function pr_timelockedavg(obj)
        end
        %% multimodal old and new
        
       
            
        function cb_StimulationParametersTable(obj)
                            % create the Data from pars
                iData=0;
                for iTableCondition=1:numel(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll))
                    TableCond=['cond' num2str(iTableCondition)];
                    for iTableStimulator=1:numel(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond)))-1 %numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond))-1
                        iData=iData+1;
                        TableStim=['st' num2str(iTableStimulator)];
                        TableData{iData,1}=num2str(iTableCondition);
                        TableData{iData,9}='          -';
                        TableData{iData,10}='          -';
                        TableData{iData,11}='          -';
                        TableData{iData,12}='          -';
                        if( isfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim),'si'))
                            TableData{iData,2}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,1});
                            
                            %check here what has been saved and use that
                            if(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_units==1)
                                TableData{iData,3}='%MSO';
                                TableData{iData,13}='          -';
                            else
                                TableData{iData,3}='%MT';
                                TableData{iData,13}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).threshold;
                            end
                        end
                        
                        if( isfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim),'stim_device'))
                            TableData{iData,4}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_device{1,1}; end
                        
                        if( isfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim),'pulse_count'))
                            TableData{iData,6}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).pulse_count); end
                        if( isfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim),'stim_mode'))
                            
                            switch obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_mode
                                case 'single_pulse'
                                    TableData{iData,5}='Single Pulse';
                                case 'paired_pulse'
                                    TableData{iData,5}='Paired Pulse';
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,2}
                                    TableData{iData,9}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,2});
                                    TableData{iData,10}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,3});
                                case 'train'
                                    TableData{iData,5}='Train';
                                    TableData{iData,11}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,2});
                                    TableData{iData,12}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).pulse_count);
                                    TableData{iData,6}=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).si_pckt{1,3});
                            end
                        end
                        if( isfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim),'stim_timing'))
                            TableData{iData,7}=mat2str(cell2mat(horzcat((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).(TableStim).stim_timing(1,:))))); end
                        TableData{iData,8}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).targetChannel{1,1};
                    end
                    if numel(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond)))==1
                        TableData{iData+1,1}=num2str(iTableCondition);
                        TableData{iData+1,8}=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(TableCond).targetChannel{1,1};
                    end
                end
                if (isempty(obj.hw.device_added2_listbox.string))
                    obj.hw.device_added2_listbox.string={'Select'};
                end
                % create the table and load the data
                table=uitable( 'Parent', obj.pi.mm.r0v2r1);
                table.Data=TableData;%cell(6,12); % the row number comes from above
                table.FontSize=10;
                table.ColumnName = {'Condition #','TS Intensity','Intensity Units','Stimulator','Pulse Mode','# of Pulses','Timing Onset (ms)','Target EMG Ch','CS Intensity','ISI (ms)','Train Freq','# of Trains','Motor Threshold (%MSO)'};
                table.ColumnFormat={[],[],{'%MSO','%MT'},obj.hw.device_added2_listbox.string,{'Single Pulse','Paired Pulse', 'Train'},[],[],{'APBr','FDIr','ADMr'},[],[],[],[],[]};
                table.ColumnWidth = {100,100,100,100,100,100,100,100,90,90,90,90,120};
                table.ColumnEditable =true(1,numel(table.ColumnName));
                table.RowStriping='on';
                table.RearrangeableColumns='on';
                table.CellEditCallback =@CellEditCallback ;

                function CellEditCallback (~,CellEditData)
                    AdditionInCondition=['cond' num2str(table.Data{CellEditData.Indices(1),1})];
%                     table.Data{:,1}
% num2str(table.Data{CellEditData.Indices(1),1})
% gp=cellfun(@str2double ,table.Data(:,1))
% str2double(table.Data{CellEditData.Indices(1),1})
%                     ggg=find(gp==str2double(table.Data{CellEditData.Indices(1),1}))
% %                     find(table.Data{:,1}==table.Data{CellEditData.Indices(1),1})
                    AdditionInStimulator=['st' num2str(find(find(cellfun(@str2double ,table.Data(:,1))==str2double(table.Data{CellEditData.Indices(1),1}))==CellEditData.Indices(1)))];
                    opts               =    [];
                    opts.WindowStyle   =    'modal';
                    opts.Interpreter   =    'none';
                    switch CellEditData.Indices(2)
                        case 2 %TS Intensity
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,1}=str2double(CellEditData.NewData);
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si=CellEditData.NewData;
                        case 3 %Intensity Units
                            switch CellEditData.NewData
                                case '%MSO'
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_units=1;
                                case '%MT'
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_units=0;
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold='NaN';

                            end

                        case 4 %Stimulator
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_device=cellstr(CellEditData.NewData);

                        case 5 %Pulse Mode
                            switch CellEditData.NewData
                                case 'Single Pulse'
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='single_pulse';
                                case 'Paired Pulse'
                                    disp ????????????????????????????????????????????????????
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='paired_pulse';
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=NaN;
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=NaN;

                                case 'Train'
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_mode='train';
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=NaN;
                                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=NaN;
                            end

                        case 6 %# of Pulses
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).pulse_count=str2double(CellEditData.NewData);
%AAJ: idher add kero k Stimulation Mode bhi nill ho jaye units bhi Nill ho
%jaye intensity bhi khtam ho jaye matlab jese he pulse 0 zero ho to sirf vo
%reh jaye to jab only stimulator add kerty hein to ata he
                            if(str2double(CellEditData.NewData)==0)
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing{1,1}=[];
                            else
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing{1,str2double(CellEditData.NewData)}=NaN;
                            end

                        case 7 %Timing Onset (ms)
                            CellEditDataTimingOnset=[];
                            CellEditDataTimingOnset=num2cell(eval(CellEditData.NewData));
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).stim_timing=CellEditDataTimingOnset;

                        case 8 %Target EMG Ch
                            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).targetChannel=cellstr(CellEditData.NewData);

                        case {11,12} %Train Freq, # of Trians
                            if ~(strcmp(table.Data{CellEditData.Indices(1),5},'Train'))
                                table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                                errordlg('Train Frequency and # of Trians are only Editable for the "Train" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
                            else
                                switch CellEditData.Indices(2)
                                    case 11
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=str2double(CellEditData.NewData);
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).freq=CellEditData.NewData;
                                    case 12
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=str2double(CellEditData.NewData);
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).pulsesNo=CellEditData.NewData;
                                end

                            end
                        case {9,10} % CS Intensity, ISI (ms)
                            if ~(strcmp(table.Data{CellEditData.Indices(1),5},'Paired Pulse'))
                                table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                                errordlg('CS Intensity and ISI are only Editable for the "Paired Pulse" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
                            else
                                switch CellEditData.Indices(2)
                                    case 9
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,2}=str2double(CellEditData.NewData);
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).cs=CellEditData.NewData;
                                    case 10
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).si_pckt{1,3}=str2double(CellEditData.NewData);
                                        obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).isi=CellEditData.NewData;
                                end

                            end
                        case 13
                            if ~(strcmp(table.Data{CellEditData.Indices(1),3},'%MT'))
                                table.Data(CellEditData.Indices(1),CellEditData.Indices(2))=cellstr('          -');
                                errordlg('The selected Stimulation Intensity Units are %MSO, change it to %MT from its dropdown menu if you desire to update this value to a specific threshold','Warning | BEST Toolbox',opts);
                            else
                                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(AdditionInCondition).(AdditionInStimulator).threshold=CellEditData.NewData;

                            end
                    end
                    %Improvement Note :Requirement 96
                    obj.pi_mep;
                    
                    
                    
                    
                    %AAJ: add a new uimenu in table for add a condition,
                    %add a stimulator to this condition, delete a
                    %condition, delete a stimulator
                    
                    
%                      function CellSelectionCallback(~,CellSelectionData)
%                     opts=[];
%                     opts.WindowStyle='modal';
%                     opts.Interpreter='none';
%                     CellSelectionData.Indices
%                     switch CellSelectionData.Indices(2)
%                         case {11,12}
%                             if ~(strcmp(table.Data{CellSelectionData.Indices(1),5},'Train'))
%                                 
%                             errordlg('Train Frequency and # of Trians are only Editable for the "Train" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
%                             end
%                         case {9,10}
%                             if ~(strcmp(table.Data{CellSelectionData.Indices(1),5},'Paired Pulse'))
%                             errordlg('CS Intensity and ISI are only Editable for the "Paired Pulse" Pulse Mode, change Pulse Mode respectively if you desire to set this parameter','Warning | BEST Toolbox',opts);
%                             end
%                     end
%                 end
                end
                

        end

        function cb_pi_mm_Nconditions(obj)
           
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
                obj.pi.mm.cond.(cd).ax.YTickLabel={'','Target Channel',''};
                plot(0:0.01:10,rand(1,1001)*0.30-0.15,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag','empty'); % 12-Mar-2020 07:37:17
                text(2.5,0+0.20,['Channel Name:[' char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).targetChannel) ']'],'VerticalAlignment','bottom','HorizontalAlignment','center','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','ButtonDownFcn',@obj.cb_pi_mm_targetChannel) % 11-Mar-2020 14:49:00
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
                    obj.pi.mm.cond.(cd).ax.YTickLabel={'',char(yticklab),'Target Channel',''};
                    text(0,-1*obj.pi.mm.stim.(cd).no,char(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_device),'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@obj.cb_pi_mm_output_device)
                    sprintf('here it is %d ----------------------------------------------------',obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count)
                    for ipulses=1:obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count
                        disp NOTENTERED=============================================================
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
                                                            disp HEHEHEHEHEHEHEHEHEHHEHEHEHEHEEEH

                                    SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MSO'];
                                else 
                                    SinglePulseAnnotation=['TS: [' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt{1,1}) '] %MT'];
                                end
                                %AAJ: idher ye banao jese oper hehehehehe
                                %vala bnaya he pp aur train dono k lye
                                text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,SinglePulseAnnotation,'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_sp_inputfig) % 11-Mar-2020 14:49:00
                            case 'paired_pulse'
                                obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                                text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{'TS:[?], CS:[?] %MSO', 'ISI:[?] ms'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_pp_inputfig) % 11-Mar-2020 14:49:00
                            case 'train'
                                obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('train');
                                obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{'Pulses:[?], f:[?] Hz', 'TS:[?] %MSO'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_train_inputfig); % 11-Mar-2020 14:49:00
                        end
                        
                        
                        % delete the previous plot
                        delete(obj.pi.mm.stim.(cd).(st).plt)
                        % make the x and y vector for new one
                        x=[];
                        y=[];
                        for i=1:obj.pi.mm.stim.(cd).(st).pulse_count
                            switch char(obj.pi.mm.stim.(cd).(st).pulse_types{1,i})
                                case 'single_pulse'
                                    disp sp
                                    x{i}=([i i i+0.15 i+0.15]);
                                    y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                case 'paired_pulse'
                                    disp pp
                                    x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40];
                                    y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                                case 'train'
                                    disp train
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
                        obj.pi.mm.stim.(st).pulse_time=text(obj.pi.mm.stim.(cd).(st).pulse_count-1+0.5,-obj.pi.mm.stim.(cd).slctd-0.05,['t:' num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing{1,ipulses}) 'ms'],'VerticalAlignment','top','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_timing)
                        
                        obj.pi.mm.stim.(st).pulse_arrow1=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1 obj.pi.mm.stim.(cd).(st).pulse_count-1+1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                        obj.pi.mm.stim.(st).pulse_arrow2=drawArrow([obj.pi.mm.stim.(cd).(st).pulse_count-1+1 obj.pi.mm.stim.(cd).(st).pulse_count-1],[-obj.pi.mm.stim.(cd).slctd-0.05 -obj.pi.mm.stim.(cd).slctd-0.05])
                        
                        
                        if(obj.pi.mm.cond.(cd).ax.XLim(2)<obj.pi.mm.stim.(cd).(st).pulse_count+1)
                            obj.pi.mm.cond.(cd).ax.XLim(2)=obj.pi.mm.stim.(cd).(st).pulse_count+1;
                        end
                        
                    end
                    
                end
                %make pulses
                
                
                
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
                disp PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
                conditionIndex=length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll));
                cond_duplicated_from=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                cond_duplicated_to=['cond' num2str(conditionIndex+1)];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_to)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_from);
                obj.pi_multimodal_ioc;
                obj.func_load_multimodal_par;
            end
            function cb_pr_mm_deleteCondition(~,~)
                                disp PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

                condsAll_fieldnames=fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll);
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=rmfield(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll,char(condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)));
                condsAll_fieldnames(obj.pi.mm.tab.SelectedChild)=[];
                for deleteIndex_condition=1:(length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll)))
                    cond_resorted_afterdelete=['cond' num2str(deleteIndex_condition)];
                    condsAll_new.(cond_resorted_afterdelete)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(char(condsAll_fieldnames(deleteIndex_condition)));
                end
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll=condsAll_new;
                obj.pi_multimodal_ioc;
                obj.func_load_multimodal_par;
            end
        end
        function cb_pi_mm_conditions(obj)
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
            obj.pi.mm.cond.(cd).ax.YTickLabel={'','Target Channel',''};
            plot(0:0.01:10,rand(1,1001)*0.30-0.15,'Color','k','parent',obj.pi.mm.cond.(cd).ax,'LineWidth',2,'Tag','empty'); % 12-Mar-2020 07:37:17
            text(2.5,0+0.20,'Channel Name:[?]','VerticalAlignment','bottom','HorizontalAlignment','center','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','ButtonDownFcn',@obj.cb_pi_mm_targetChannel) % 11-Mar-2020 14:49:00
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).targetChannel=cellstr('NaN');
            obj.pi.mm.stim.(cd).no=0;
            function cb_pr_mm_duplicateCondition(~,~)
                conditionIndex=length(fieldnames(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll));
                cond_duplicated_from=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                cond_duplicated_to=['cond' num2str(conditionIndex+1)];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_to)=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cond_duplicated_from);
                obj.pi_multimodal_ioc;
                obj.func_load_multimodal_par;
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
                obj.pi_multimodal_ioc;
                obj.func_load_multimodal_par;
            end
                        obj.cb_StimulationParametersTable;

            
        end
        function cb_pi_mm_stim(obj)
            
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
            obj.pi.mm.cond.(cd).ax.YTickLabel={'',char(yticklab),'Target Channel',''};
            text(0,-1*obj.pi.mm.stim.(cd).no,'click to tag device','VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','Tag',num2str(obj.pi.mm.stim.(cd).no),'ButtonDownFcn',@obj.cb_pi_mm_output_device)
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
            obj.cb_StimulationParametersTable;
        end
        function cb_pi_mm_pulse(obj,source,~)
            % 11-Mar-2020 18:13:21
            cd=['cd' num2str(obj.pi.mm.tab.SelectedChild)];
            condStr=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
            
            %             obj.pi.mm.stim.(cd).slctd=1 ;
            
            
            st=['st' num2str(obj.pi.mm.stim.(cd).slctd)];
            obj.pi.mm.stim.(cd).(st).pulse_count=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count+1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulse_count=obj.pi.mm.stim.(cd).(st).pulse_count;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode=cellstr(source.Tag);
            switch source.Tag
                case 'single_pulse'
                    obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('single_pulse');
                    text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.41,'       TS:[NaN] %MSO','VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_sp_inputfig) % 11-Mar-2020 14:49:00
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si='NaN'; %only 1 SI is allowed as a standard model of generalization
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).threshold='';
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode='single_pulse';
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt={NaN};
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing={NaN};

                case 'paired_pulse'
                    obj.pi.mm.stim.(cd).(st).pulse_types{1,obj.pi.mm.stim.(cd).(st).pulse_count}=cellstr('paired_pulse');
                    text(obj.pi.mm.stim.(cd).(st).pulse_count-0.25,-obj.pi.mm.stim.(cd).slctd+0.4,{'TS:[NaN], CS:[NaN] %MSO', 'ISI:[NaN] ms'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_pp_inputfig) % 11-Mar-2020 14:49:00
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
                    obj.pi.mm.stim.(st).pulse_specs=text(obj.pi.mm.stim.(cd).(st).pulse_count,-obj.pi.mm.stim.(cd).slctd+0.4,{'Pulses:[NaN], f:[NaN] Hz', 'TS:[NaN] %MSO'},'VerticalAlignment','bottom','Color',[0.50 0.50 0.50],'FontSize',7,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_train_inputfig); % 11-Mar-2020 14:49:00
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si='NaN'; %only 1 SI is allowed as a standard model of generalization
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).pulsesNo='NaN'; %only 1 SI is allowed as a standard model of generalization
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).freq='NaN'; %only 1 SI is allowed as a standard model of generalization
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_units=1; %if 1 then its mso if 0 then its threshold
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).threshold='';
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_mode='train';
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).si_pckt={NaN,NaN,NaN};
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(condStr).(st).stim_timing={NaN};
            end
            
            
            % delete the previous plot
            delete(obj.pi.mm.stim.(cd).(st).plt)
            % make the x and y vector for new one
            x=[];
            y=[];
            for i=1:obj.pi.mm.stim.(cd).(st).pulse_count
                switch char(obj.pi.mm.stim.(cd).(st).pulse_types{1,i})
                    case 'single_pulse'
                        disp sp
                        x{i}=([i i i+0.15 i+0.15]);
                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                    case 'paired_pulse'
                        disp pp
                        x{i}=[i i i+0.15 i+0.15 i+0.25 i+0.25 i+0.40 i+0.40];
                        y{i}=[-obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd+0.20 -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd+0.4 -obj.pi.mm.stim.(cd).slctd];
                    case 'train'
                        disp train
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
            obj.pi.mm.stim.(st).pulse_time=text(obj.pi.mm.stim.(cd).(st).pulse_count-1+0.5,-obj.pi.mm.stim.(cd).slctd-0.05,'t:NaN ms','VerticalAlignment','top','Color',[0.50 0.50 0.50],'FontSize',9,'FontAngle','italic','UserData',[obj.pi.mm.stim.(cd).(st).pulse_count,obj.pi.mm.stim.(cd).slctd],'ButtonDownFcn',@obj.cb_pi_mm_timing)
            
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
            obj.cb_StimulationParametersTable;
        end
        
        function cb_pi_mm_output_device(obj,source,~)
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
                    obj.cb_StimulationParametersTable;

                end
                
            end
        end
        function cb_pi_mm_timing(obj,source,~)
            prompt = {'Time (mili-seconds):'};
            dlgtitle = 'Insert Time | BEST Toolbox';
            dims = [1 60];
            definput = {'NaN'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            source.String=['t: ', char(answer), ' ms'];
            cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
            st=['st' num2str(source.UserData(2))];
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_timing(source.UserData(1))=num2cell(str2double(answer));
            obj.cb_StimulationParametersTable;

        end
        function cb_pi_mm_sp_inputfig(obj,source,~)
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
            threshold=uicontrol( 'Style','edit','Parent', r3 ,'FontSize',11);
            mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
            mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
            mt_btn_listbox_str=['Select' mt_btn_listbox_str];
            uiextras.HBox('Parent',r3)
            th_dropdown=uicontrol( 'Style','popupmenu','Parent', r3 ,'FontSize',11,'String',mt_btn_listbox_str);     % 11-Mar-2020 14:48:46                                                                  % 1297
            set( r3, 'Widths', [210 80 20 100]);
            
            
            uicontrol( 'Parent', c1 ,'Style','PushButton','String','OK','FontWeight','Bold','Callback',@(~,~)cb_ok);
            
            set(c1, 'Heights', [25 25 25 25])
            f.Position(3)=430;
            f.Position(4)=150;
            function cb_ok
                source.String=['TS:' si.String ' %MSO']; % 11-Mar-2020 14:48:28
                cd=['cond' num2str(obj.pi.mm.tab.SelectedChild)];
                st=['st' num2str(source.UserData(2))];
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si=si.String; %only 1 SI is allowed as a standard model of generalization
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_units=units_mso.Value; %if 1 then its mso if 0 then its threshold
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).threshold=threshold.String;
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).stim_mode='single_pulse';
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).condsAll.(cd).(st).si_pckt={str2double(si.String)};
                obj.cb_StimulationParametersTable;

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
        function cb_pi_mm_pp_inputfig(obj,source,~)
            f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
            c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
            r1=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r1,'String','Test Stimulus Intensities (TS):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            si=uicontrol( 'Style','edit','Parent', r1 ,'String','NaN','FontSize',11);
            set( r1, 'Widths', [250 200]);
            
            r2a=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r2a,'String','Condition Stimulus Intensities (CS):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
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
                            obj.cb_StimulationParametersTable;

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
        function cb_pi_mm_train_inputfig(obj,source,~)
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
                            obj.cb_StimulationParametersTable;

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
        function cb_pi_mm_targetChannel(obj,source,~)
            f=figure('ToolBar','none','MenuBar','none','Name','Insert Parameters | BEST Toolbox','NumberTitle','off');
            c1=uix.VBox('parent',f,'Padding',10,'Spacing',10);
            
            %             r0=uix.HBox('parent',c1);
            %             uicontrol( 'Style','text','Parent', r0,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             str_in_device(1)= (cellstr('Select'));
            %             str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            %             inputDevice=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',str_in_device);
            %             set( r0, 'Widths', [250 200]);
            
            r1=uix.HBox('parent',c1);
            uicontrol( 'Style','text','Parent', r1,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            targetChannels=uicontrol( 'Style','edit','Parent', r1 ,'FontSize',11);
            set( r1, 'Widths', [250 200]);
            
            %             r2a=uix.HBox('parent',c1);
            %             uicontrol( 'Style','text','Parent', r2a,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             displayChannels=uicontrol( 'Style','edit','Parent', r2a ,'FontSize',11);
            %             set( r2a, 'Widths', [250 200]);
            %
            %             r2b=uix.HBox('parent',c1);
            %             uicontrol( 'Style','text','Parent', r2b,'String','MEP onset/offset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             mepOnset=uicontrol( 'Style','edit','Parent', r2b ,'FontSize',11);
            %             uiextras.HBox('Parent',r2b)
            %             mepOffset=uicontrol( 'Style','edit','Parent', r2b ,'FontSize',11);
            %             set( r2b, 'Widths', [250 90 20 90]);
            %
            %             r2=uix.HBox('parent',c1);
            %             uicontrol( 'Style','text','Parent', r2,'String','MEP Pre/Post Display Period (ms)','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             prestim_scope_plt=uicontrol( 'Style','edit','Parent', r2 ,'FontSize',11);
            %             uiextras.HBox('Parent',r2)
            %             poststim_scope_plt=uicontrol( 'Style','edit','Parent', r2 ,'FontSize',11);
            %             set( r2, 'Widths', [250 90 20 90]);
            
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
                            obj.cb_StimulationParametersTable;

                close(f)
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
            obj.pi.mep.BrainState=uicontrol( 'Style','popupmenu','Parent', r0 ,'FontSize',11,'String',{'Independent','Dependent'},'Callback',@cb_UniversalPanelAdaptation);
            set( r0, 'Widths', [150 -2]);
            BrainStateParametersPanel=uix.Panel( 'Parent', obj.pi.mep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Brain State Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_BrainStateParametersPanel
            DisplayParametersPanel=uix.Panel( 'Parent', obj.pi.mep.r0v1,'Padding',5,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Display Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            cb_DisplayParametersPanel
            expModr2=uiextras.HBox( 'Parent', obj.pi.mep.r0v1,'Spacing', 5, 'Padding', 5 );
            uicontrol( 'Style','text','Parent', expModr2,'String','Trials Per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.TrialsPerCondition=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','TrialsPerCondition','callback',@cb_par_saving);
            expModr2.Widths=[150 -2];
            
            %row3
            uicontrol( 'Style','text','Parent', obj.pi.mep.r0v1,'String','','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            %row4
            r4=uiextras.HBox( 'Parent', obj.pi.mep.r0v1,'Spacing', 5, 'Padding', 5 );
            obj.pi.mep.cond.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','+','FontSize',16,'FontWeight','Bold','HorizontalAlignment','center','Tooltip','Click to Add a new Condition','Callback',@(~,~)obj.cb_pi_mm_conditions);%add condition
            obj.pi.mep.stim.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','Position',[0 0 1 1],'units','normalized','CData',obj.icons.stimulator,'Tooltip','Click to Add a new Stimulator on this Condition','Callback',@(~,~)obj.cb_pi_mm_stim); %add stimulator
            obj.pi.mep.sp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.single_pulse,'Tooltip','Click to Add a Single-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','single_pulse','Callback',@obj.cb_pi_mm_pulse); %add single pulse
            obj.pi.mep.pp.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.paired_pulse,'Tooltip','Click to Add a Paired-Pulse on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','paired_pulse','Callback',@obj.cb_pi_mm_pulse);%add burst or train
            obj.pi.mep.train.btn=uicontrol( 'Parent', r4 ,'Style','PushButton','String','','FontWeight','Bold','HorizontalAlignment','center','CData',obj.icons.train,'Tooltip','Click to Add a Train or Burst on selected stimulator (selected stimulator is highlighted in blue colour)','Tag','train','Callback',@obj.cb_pi_mm_pulse);%add paired pulse
            set( r4, 'Widths', [55 55 55 55 55]);

            
            obj.pi.mep.update=uicontrol( 'Parent', obj.pi.mep.r0v1 ,'Style','PushButton','String','Run','FontWeight','Bold','HorizontalAlignment','center','Callback',@(~,~)cb_run_mep); %Run
            
            cb_SetHeights;
            
            
            obj.pi.mep.r0v2 = uix.VBox( 'Parent', obj.pi.mep.r0, 'Spacing', 5, 'Padding', 0); %uicontext menu to duplicate or delete a condition goes here
            obj.pi.mm.r0v2r1=uix.Panel( 'Parent', obj.pi.mep.r0v2,'Padding',0,'Units','normalized','FontSize',8 ,'Units','normalized','Title','Stimulation Parameters' ,'FontWeight','normal','TitlePosition','centertop');
            obj.cb_StimulationParametersTable;
            
            obj.pi.mm.tab = uiextras.TabPanel( 'Parent', obj.pi.mep.r0v2, 'Padding', 5 );
            obj.pi.mep.r0v2.Heights=[200 -1];
            set(obj.pi.mep.r0,'Widths',[-1.45 -3]);  
            obj.pi.mep.cond.no=0;
            obj.cb_pi_mm_Nconditions;
            
            function cb_run_mep()

%                 obj.bst.inputs=[];
%                 obj.bst.inputs=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr);

%                 obj.bst.factorizeConditions;
obj.bst.best_mep;
            end
            function cb_UniversalPanelAdaptation(~,~)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).BrainState=obj.pi.mep.BrainState.Value;
                cb_BrainStateParametersPanel
                cb_DisplayParametersPanel
                cb_SetHeights
                obj.func_load_mep_par;
            end
            function cb_BrainStateParametersPanel(~,~)
                switch obj.pi.mep.BrainState.Value
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
                        expModr1=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr1,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        str_in_device(1)= (cellstr('Select'));
                        str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                        obj.pi.mep.InputDevice=uicontrol( 'Style','popupmenu','Parent', expModr1 ,'FontSize',11,'String',str_in_device,'Tag','InputDevice','callback',@cb_par_saving);
                        expModr1.Widths=[150 -2];
                        
                                                % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MontageChannels=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageChannels','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MontageWeights=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','MontageWeights','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_row8 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Frequency Band:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.FrequencyBand=uicontrol( 'Style','popupmenu','Parent', mep_panel_row8 ,'FontSize',11,'String',{'Alpha (8-14 Hz)','Theta (4-7 Hz)','Beta  (15-30 Hz)'},'Tag','FrequencyBand','callback',@cb_par_saving);
                        set( mep_panel_row8, 'Widths', [150 -2]);
                        
                        mep_panel_row8z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row8z,'String','Peak Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.PeakFrequency=uicontrol( 'Style','edit','Parent', mep_panel_row8z ,'FontSize',11,'Tag','PeakFrequency','Callback',@cb_par_saving); 
                        set( mep_panel_row8z, 'Widths', [150 -2]);
                        
                        % row 2
                        mep_panel_row2 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.Phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Tag','Phase','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2, 'Widths', [150 -2]);
                        
                        mep_panel_13 = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amp Distribution:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.AmplitudeLowBound=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeLowBound','Callback',@cb_par_saving);
                        obj.pi.mep.AmplitudeHighBound=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Tag','AmplitudeHighBound','Callback',@cb_par_saving);
                        obj.pi.mep.AmplitudeUnits=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Percentile','Absolute (micro Volts)'},'Tag','AmplitudeUnits','Callback',@cb_par_saving);
                        set( mep_panel_13, 'Widths', [150 -2 -2 -2]);
                        
                        mep_panel_row2z = uix.HBox( 'Parent', expModvBox, 'Spacing', 5, 'Padding', 5  );
                        uicontrol( 'Style','text','Parent', mep_panel_row2z,'String','Amp Assignment Period(s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        uicontrol( 'Style','edit','Parent', mep_panel_row2z ,'FontSize',11,'Tag','AmplitudeAssignmentPeriod','Callback',@cb_par_saving); %,'Callback',@obj.cb_eegtms_target_muscle
                        set( mep_panel_row2z, 'Widths', [150 -2]);
                        
                        expModr2c=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2c,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.ITI=uicontrol( 'Style','edit','Parent', expModr2c ,'FontSize',11,'Tag','ITI','callback',@cb_par_saving);
                        expModr2c.Widths=[150 -2];
                        expModvBox.Heights=[30 35 35 35 35 35 35 42 35];
                end
                
            end
            function cb_DisplayParametersPanel
                switch obj.pi.mep.BrainState.Value
                    case 1
                        expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr3=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr3,'String','MEP Onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MEPOnset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','MEPOnset','callback',@cb_par_saving);
                        obj.pi.mep.MEPOffset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','MEPOffset','callback',@cb_par_saving);
                        expModr3.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.mep.EMGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModvBox.Heights=[45 45 45];
%                         cb_SetHeights
                    case 2
                         expModvBox=uix.VBox( 'Parent', DisplayParametersPanel, 'Spacing', 0, 'Padding', 0  );
                        expModr2=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr2,'String','EMG Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayChannels=uicontrol( 'Style','edit','Parent', expModr2 ,'FontSize',11,'Tag','EMGDisplayChannels','callback',@cb_par_saving);
                        expModr2.Widths=[150 -2];
                        
                        expModr3=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr3,'String','MEP Onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.MEPOnset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','MEPOnset','callback',@cb_par_saving);
                        obj.pi.mep.MEPOffset=uicontrol( 'Style','edit','Parent', expModr3 ,'FontSize',11,'Tag','MEPOffset','callback',@cb_par_saving);
                        expModr3.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EMG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EMGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.mep.EMGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EMGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModr4=uiextras.HBox( 'Parent', expModvBox,'Spacing', 5, 'Padding', 5 );
                        uicontrol( 'Style','text','Parent', expModr4,'String','EEG Display Period (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                        obj.pi.mep.EEGDisplayPeriodPre=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPre','callback',@cb_par_saving);
                        obj.pi.mep.EEGDisplayPeriodPost=uicontrol( 'Style','edit','Parent', expModr4 ,'FontSize',11,'Tag','EEGDisplayPeriodPost','callback',@cb_par_saving);
                        expModr4.Widths=[150 -2 -2];
                        
                        expModvBox.Heights=[45 45 45 45];
%                         cb_SetHeights
                end
            end       
            function cb_SetHeights
                 switch obj.pi.mep.BrainState.Value
                    case 1
                        set(obj.pi.mep.r0v1,'Heights',[40 90 170 40 -3 55 55])
                    case 2
                        set(obj.pi.mep.r0v1,'Heights',[40 350 220 40 -3 55 55])
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
        function pr_mepold(obj)
            obj.pr.mep.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            m_mep=uicontextmenu(obj.fig.handle);
            uimenu(m_mep,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_mep_export);
            obj.pr.mep.vb = uix.VBox( 'Parent', obj.pr.mep.handle, 'Spacing', 5, 'Padding', 5  );
            
            
            
            mep_pr1 = uix.HBox( 'Parent', obj.pr.mep.vb, 'Spacing', 5, 'Padding', 0  );
            uiextras.HBox( 'Parent', mep_pr1)
            
            uiextras.HBox( 'Parent', mep_pr1)
            
            
            obj.pr.mep.total_trials_label=uicontrol( 'Style','text','Parent', mep_pr1,'String','Total Trials','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            
            obj.pr.mep.trial_no_label=uicontrol( 'Style','text','Parent', mep_pr1,'String','Trial No.','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            if(strcmp(obj.bst.inputs.stim_mode,'MSO'))
                obj.pr.mep.stim_intensity_label=uicontrol( 'Style','text','Parent', mep_pr1,'String','Intensity (%MSO)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            else
                obj.pr.mep.stim_intensity_label=uicontrol( 'Style','text','Parent', mep_pr1,'String','Stim Intensity (%MT)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            end
            obj.pr.mep.iti_label=uicontrol( 'Style','text','Parent', mep_pr1,'String','ITI (s)','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep_pr1)
            set(mep_pr1,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            
            mep_pr2 = uix.HBox( 'Parent', obj.pr.mep.vb, 'Spacing', 5, 'Padding', 0  );
            uiextras.HBox( 'Parent', mep_pr2)
            obj.pr.mep.current_trial_label=uicontrol( 'Style','text','Parent', mep_pr2,'String','Current Trial','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_totaltrial_no=uicontrol( 'Style','edit','Parent', mep_pr2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_trial=uicontrol( 'Style','edit','Parent', mep_pr2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_si=uicontrol( 'Style','edit','Parent', mep_pr2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_iti=uicontrol( 'Style','edit','Parent', mep_pr2,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep_pr2)
            set(mep_pr2,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            mep_pr3 = uix.HBox( 'Parent', obj.pr.mep.vb, 'Spacing', 5, 'Padding', 1  );
            
            uiextras.HBox( 'Parent', mep_pr3)
            obj.pr.mep.next_trial_label=uicontrol( 'Style','text','Parent', mep_pr3,'String','Next Trial','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.next_totaltrial_no=uicontrol( 'Style','edit','Parent', mep_pr3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.next_trial=uicontrol( 'Style','edit','Parent', mep_pr3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.next_si=uicontrol( 'Style','edit','Parent', mep_pr3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.next_iti=uicontrol( 'Style','edit','Parent', mep_pr3,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep_pr3)
            set(mep_pr3,'Widths',[-0.3 100 100 100 130 100 -0.3])
            
            
            obj.pr.mep.mep_pr4 = uix.HBox( 'Parent', obj.pr.mep.vb, 'Spacing', 5, 'Padding', 5  );
            
            
            set(obj.pr.mep.vb,'Heights',[30 30 30 -9])
            
            
            obj.pr_mep6
            
            %             obj.pr.mep.axes1=axes( 'Parent', obj.pr.mep.handle,'Units','normalized','Tag','mep1','uicontextmenu',m_mep,'UserData','umikhankhan');
            
            % %             switch numel(obj.bst.inputs.display_scopes)
            % %                 case 0
            % %                     % do nothing, keep the space empty since no
            % %                     % visualization is requrored but show analytics
            % %                 case 1
            % %                     obj.pr_mep1;
            % %                 case 2
            % %                     obj.pr_mep2;
            % %                 case 3
            % %                     obj.pr_mep3;
            % %                 case 4
            % %                     obj.pr_mep4;
            % %                 case 5
            % %                     obj.pr_mep5;
            % %                 case 6
            % %                     obj.pr_mep6;
            % %             end
            
            
            % %             obj.pr.mep.axes1=axes( 'Parent', obj.pr.mep.handle,'Units','normalized','Tag','mep1','uicontextmenu',m_mep,'UserData','umikhankhan');
            % %             obj.pr.mep.axes2=axes( 'Parent', obj.pr.mep.handle,'Units','normalized','Tag','mep2','uicontextmenu',m_mep,'UserData','umikhankhan');
            % %             obj.pr.mep.axes3=axes( 'Parent', obj.pr.mep.handle,'Units','normalized','Tag','mep3','uicontextmenu',m_mep,'UserData','umikhankhan');
            
        end
        function pr_mep1(obj)
            
            obj.pr.mep.clab1=uix.Panel( 'Parent', obj.pr.mep.mep_pr4, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            
            
            
        end
        function pr_mep2(obj)
            mep2_grid=uiextras.GridFlex('Parent',obj.pr.mep.mep_pr4, 'Spacing', 5 );
            
            %furst ax panel
            obj.pr.mep.clab1=uix.Panel( 'Parent',  mep2_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            
            
            %second ax panel
            
            obj.pr.mep.clab2=uix.Panel( 'Parent',  mep2_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab2, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_2_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_2=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_2_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_2=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax2=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            
            
            set(mep2_grid,'ColumnSizes',[-1 -1]);
            
            
            
            
        end
        function pr_mep3(obj)
            mep3_grid=uiextras.GridFlex('Parent',obj.pr.mep.mep_pr4, 'Spacing', 5 );
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep3_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab2=uiextras.Panel( 'Parent',  mep3_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab3=uiextras.Panel( 'Parent',  mep3_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            set(mep3_grid,'ColumnSizes',[-1 -1]);
            
        end
        function pr_mep4(obj)
            mep4_grid=uiextras.GridFlex('Parent',obj.pr.mep.mep_pr4, 'Spacing', 5 );
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep4_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab2=uiextras.Panel( 'Parent',  mep4_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab3=uiextras.Panel( 'Parent',  mep4_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab4=uiextras.Panel( 'Parent',  mep4_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            
            set(mep4_grid,'ColumnSizes',[-1 -1],'RowSizes',[-1 -1]);
        end
        function pr_mep5(obj)
            mep5_grid=uiextras.GridFlex('Parent',obj.pr.mep.mep_pr4, 'Spacing', 5 );
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep5_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab2=uiextras.Panel( 'Parent',  mep5_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab3=uiextras.Panel( 'Parent',  mep5_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab4=uiextras.Panel( 'Parent',  mep5_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mep.clab5=uiextras.Panel( 'Parent',  mep5_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            uiextras.HBox( 'Parent', mep5_grid)
            
            
            set(mep5_grid,'ColumnSizes',[-1 -1 -1],'RowSizes',[-1 -1 -1]);
        end
        function pr_mep6(obj)
            mep6_grid=uiextras.GridFlex('Parent',obj.pr.mep.mep_pr4, 'Spacing', 5 );
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            %             obj.pr.mep.clab2=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            %
            %             obj.pr.mep.clab3=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            %             obj.pr.mep.clab4=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            %             obj.pr.mep.clab5=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            %             obj.pr.mep.clab6=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            %
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            obj.pr.mep.clab1=uiextras.Panel( 'Parent',  mep6_grid, 'Padding', 5 ,'Units','normalized','Title', 'APBr','FontWeight','bold','FontSize',12,'TitlePosition','centertop' );
            
            mep1_vb=uix.VBox( 'Parent',  obj.pr.mep.clab1, 'Spacing', 5, 'Padding', 1  );
            
            mep1_r1 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            uiextras.HBox( 'Parent', mep1_r1)
            obj.pr.mep.current_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Current MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.current_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized','Enable','inactive');
            obj.pr.mep.mean_mep_1_label=uicontrol( 'Style','text','Parent', mep1_r1,'String','Mean MEP Amp','FontSize',11,'HorizontalAlignment','center','Units','normalized');
            obj.pr.mep.mean_mep_1=uicontrol( 'Style','edit','Parent', mep1_r1,'FontSize',11,'HorizontalAlignment','center','Units','normalized');
            uiextras.HBox( 'Parent', mep1_r1)
            set(mep1_r1,'Widths',[-0.3 130 70 130 70 -0.3])
            
            mep1_r2 = uix.HBox( 'Parent', mep1_vb, 'Spacing', 5, 'Padding', 1  );
            obj.pr.mep.ax1=axes( 'Parent',  mep1_r2,'Units','normalized');
            set(mep1_vb,'Heights',[30 -10])
            
            
            set(mep6_grid,'ColumnSizes',[-1 -1 -1],'RowSizes',[-1 -1]);
        end
        
        function default_par_mep(obj)
            % Editing Rule: Values should be Integers, Strings should
            % Strings , cells are the defaults values that do not have any
            % uicontroller
            obj.info.defaults.BrainState=1;
            obj.info.defaults.TrialsPerCondition='10';
            obj.info.defaults.InputDevice=1;
            obj.info.defaults.ITI='4';
            obj.info.defaults.MontageChannels='';
            obj.info.defaults.MontageWeights='';
            obj.info.defaults.FrequencyLowBound='';
            obj.info.defaults.FrequencyHighBound='';
            obj.info.defaults.Phase='';
            obj.info.defaults.AmplitudeLowBound='';
            obj.info.defaults.AmplitudeHighBound='';
            obj.info.defaults.AmplitudeUnits='1';
            obj.info.defaults.EMGDisplayChannels='';
            obj.info.defaults.MEPOnset='15';
            obj.info.defaults.MEPOffset='50';
            obj.info.defaults.EMGDisplayPeriodPre='50';
            obj.info.defaults.EMGDisplayPeriodPost='150';
            obj.info.defaults.EEGDisplayPeriodPre='100';
            obj.info.defaults.EEGDisplayPeriodPost='100';
            obj.info.defaults.EMGDisplayYLimMax={3000};
            obj.info.defaults.EMGDisplayYLimMin={-3000};
            obj.info.defaults.Protocol={'MEP Measurement Protocol'};

%             obj.info.defaults.expMode	=	1	;
%             obj.info.defaults.inputDevice	=	1	;
%             %             obj.info.defaults.displayChannels	=	eval('{''APBr''}')	;
%             obj.info.defaults.trials	=	10	;
%             obj.info.defaults.iti	=	4	;
%             obj.info.defaults.mepOnset	=	15	;
%             obj.info.defaults.mepOffset	=	50	;
%             obj.info.defaults.prestim_scope_plt	=	50	;
%             obj.info.defaults.poststim_scope_plt	=	150	;
%             obj.info.defaults.sub_measure_str	=	'MEP Measurement'	;
%             obj.info.defaults.measure_str   =	'Multimodal Experiment'	;
            si=[30 40 50 60 70 80]; 
            for idefaults=1:6
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
                        %Requirment 93
                    end
                elseif(isa(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(ParametersFieldNames{iLoadingParameters}),'struct')) 
                    %Do Nothing and Just Avoid
                end
            end
   
            
        end
        function cb_pi_mep_run(obj)
            % % %             obj.disable_listboxes %commented on 25feb
            %             %             delete(obj.pr.mep.axes1)
            %             delete(obj.pr.hotspot.axes1)
            %             delete(obj.pr.mt.axes_mep)
            %             delete(obj.pr.mt.axes_mtplot)
            %             delete(obj.pr.ioc.axes_mep)
            %             delete(obj.pr.ioc.axes_scatplot)
            %             delete(obj.pr.ioc.axes_fitplot)
            
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            
            obj.pi.mep.run.Enable='on';
            %             obj.pi.mep.target_muscle.Enable='off';
            obj.pi.mep.units_mso.Enable='off';
            obj.pi.mep.units_mt.Enable='off';
            obj.pi.mep.mt.Enable='off';
            obj.pi.mep.mt_btn.Enable='off';
            %             obj.pi.mep.prestim_scope_ext.Enable='off';
            %             obj.pi.mep.poststim_scope_ext.Enable='off';
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.mep.run.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.mep.target_muscle.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.mep.units_mso.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.mep.units_mt.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.mep.mt.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.mep.mt_btn.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.mep.prestim_scope_ext.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.mep.poststim_scope_ext.Enable;
            %
            
            
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.measure_str=cellstr('MEP Measurement');
            
            obj.bst.inputs.input_device=obj.pi.mep.input_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device));
            obj.bst.inputs.output_device=obj.pi.mep.output_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device));
            obj.bst.inputs.target_muscle=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            
            obj.bst.inputs.display_scopes=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes);
            
            obj.bst.inputs.stimuli=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            
            
            if(numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)==1 || numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)>2)
                obj.bst.inputs.iti=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
                disp 1stcommand
            else
                %                 obj.bst.inputs.iti=cellstr(num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti));
                obj.bst.inputs.iti={num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)};
                
                disp 2ndcommand
            end
            
            
            obj.bst.inputs.trials=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso==1)
                obj.bst.inputs.stim_mode='MSO';
                obj.bst.inputs.mt_mso=NaN;
            else
                obj.bst.inputs.stim_mode='MT';
                obj.bst.inputs.mt_mso=str2double(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt);
            end
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            %             obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            %             obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            %             obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            %             obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            %             obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            %             obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            %             obj.bst.inputs.reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).reset_pressed;
            %             obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            
            %             obj.pr_mep;
            % factors
            
            obj.bst.inputs.measure=cell(1,numel(obj.bst.inputs.display_scopes));
            obj.bst.inputs.measure(:)=obj.bst.inputs.measure_str;
            
            obj.bst.inputs.factors={obj.bst.inputs.output_device,obj.bst.inputs.display_scopes,obj.bst.inputs.measure};
            obj.pr.axesno=numel(obj.bst.inputs.factors{1})*numel(obj.bst.inputs.factors{2});
            
            obj.bst.best_mep;
            
            % obj.results_panel;
            % obj.bst.factorizeConditions;
            % obj.bst.planTrials;
            % obj.results_panel;
            %             try
            %             obj.cb_menu_save;
            
            %             obj.bst.best_mep;
            %             obj.cb_menu_save;
            %             delete(sprintf('%s.mat',obj.bst.info.save_str_runtime))
            %
            %             % saving figure
            %
            %             if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt==1)
            %                 exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            %                 sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            %                 sess=obj.info.event.current_session;
            %                 meas=obj.info.event.current_measure_fullstr;
            %                 plt='MEP_Plot';
            %                 timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.mep.axes1,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %             end
            
            % Enable on the listboxes back
            
            %             catch
            %                 disp('MEP Measurement Stopped | BEST Toolbox')
            %             end
            
            
            
            
            obj.enable_listboxes
            %             obj.pr.mep.axes1
            %             obj.pr.mep.axes1.Tag
            %             obj.pr.mep.axes1.UserData
            %             obj.bst.info.axes.mep
            %             obj.bst.info.axes.mep.Tag
            %             obj.bst.info.axes.mep.UserData
            
        end
        function cb_pi_mep_update(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx+1;
            str1=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx);
            str2='update_';
            str=[str2 str1];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).(str)=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement);
            % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=[];
            % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials=[];
            % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).rawdata=[];
            
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=obj.bst.inputs;
            obj.bst.best_trialprep;
            
            %% Font updating
            obj.bst.info.axes.mep
            obj.bst.info.axes.mep.FontSize=obj.bst.inputs.FontSize;
            %% Graph Y lim setting
            set(obj.bst.info.axes.mep,'YLim',[obj.bst.inputs.ylim_min obj.bst.inputs.ylim_max])
            y_ticks_mep=linspace(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_min,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_max,5);
            yticks(y_ticks_mep);
            
            %% Graph X lim setting
            xlim([obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(1), obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)]);
            
            
            %% MEP search window setting
            delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
            mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
            mat=unique(sort([mat1 mat2]));
            mat=unique(mat);
            xticks(mat);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):0.25:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
            
            
        end
        function cb_pi_mep_input_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device=obj.pi.mep.input_device.Value;
            obj.pi.mep.input_device.Value
            obj.pi.mep.input_device.String
            obj.pi.mep.input_device.Value
        end
        function cb_pi_mep_output_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device=obj.pi.mep.output_device.Value;
            obj.pi.mep.output_device.Value
        end
        function cb_pi_mep_display_scopes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=obj.pi.mep.display_scopes.String;
            % %             %first evalute
            % %             if(ischar(obj.pi.mep.display_scopes.String) || (iscell(eval(obj.pi.mep.display_scopes.String))))
            % %                 if(iscell(eval(obj.pi.mep.display_scopes.String)))
            % %                     cellarraysize=size(eval(obj.pi.mep.display_scopes.String))
            % %                     if(cellarraysize(1)>1)
            % %                         %error dialogue
            % %                         disp BEST Toolbox: The Display Scopes input field must be a 1 x n dimension cell array
            % %                     end
            % %                 end
            % %                 try
            % %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=eval(obj.pi.mep.display_scopes.String);
            % %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes
            % %                 catch
            % %                     disp BEST Toolbox: The Display Scopes field input can only be a Character or Cell array OR no such variable exists with this name in the MATLAB workspace
            % %                 end
            % %                 %             elseif (iscell(eval(obj.pi.mep.display_scopes.String)))
            % %                 %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=eval(obj.pi.mep.display_scopes.String);
            % %                 %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes
            % %             else
            % %                 % display error dialogue
            % %                 disp BEST Toolbox: The Display Scopes field input can only be a Character or Cell array
            % %             end
        end
        function cb_pi_mep_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.mep.target_muscle.String;
        end
        function cb_pi_mep_stimulation_intensities(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=str2num(obj.pi.mep.stimulation_intensities.String);
            obj.pi.mep.stimulation_intensities.String
        end
        function cb_pi_mep_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=(obj.pi.mep.trials_per_condition.String);
        end
        function cb_pi_mep_iti(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.mep.iti.String);
            
            % %             global opps
            % %             opps
            % %  initiliaze the global variable and then name it as per the global name
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=eval(obj.pi.mep.iti.String);
            
        end
        function cb_pi_mep_mep_onset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset=str2num(obj.pi.mep.mep_onset.String);
        end
        function cb_pi_mep_mep_offset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset=str2num(obj.pi.mep.mep_offset.String);
        end
        function cb_pi_mep_prestim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext=str2num(obj.pi.mep.prestim_scope_ext.String);
        end
        function cb_pi_mep_poststim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext=str2num(obj.pi.mep.poststim_scope_ext.String);
        end
        function cb_pi_mep_prestim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt=str2num(obj.pi.mep.prestim_scope_plt.String);
        end
        function cb_pi_mep_poststim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt=str2num(obj.pi.mep.poststim_scope_plt.String);
        end
        function cb_pi_mep_units_mso(obj)
            if(obj.pi.mep.units_mso.Value==1)
                obj.pi.mep.units_mt.Value=0;
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=(obj.pi.mep.units_mso.Value);
        end
        function cb_pi_mep_units_mt(obj)
            if(obj.pi.mep.units_mt.Value==1)
                obj.pi.mep.units_mso.Value=0;
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt=(obj.pi.mep.units_mt.Value);
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=0;
        end
        function cb_pi_mep_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt=str2num(obj.pi.mep.mt.String);
        end
        function cb_pi_mep_mt_btn(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=(obj.pi.mep.mt_btn);
            meas=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.String(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.Value);
            meas=meas{1}
            meas(meas == ' ') = '_';
            if(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.Value>1)
                try
                    obj.pi.mep.mt.String= obj.bst.sessions.(obj.info.event.current_session).(meas).results.mt
                catch
                    obj.pi.mep.mt.String=[];
                end
            else
                obj.pi.mep.mt.String=[];
            end
            obj.cb_pi_mep_mt;
        end
        function cb_pi_mep_ylim_min(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min=str2num(obj.pi.mep.ylim_min.String);
        end
        function cb_pi_mep_ylim_max(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max=str2num(obj.pi.mep.ylim_max.String);
        end
        function cb_pi_mep_FontSize(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize=str2num(obj.pi.mep.FontSize.String);
        end
        function cb_pi_mep_trials_for_mean_annotation(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation=str2num(obj.pi.mep.trials_for_mean_annotation.String);
        end
        function cb_pi_mep_trials_reset(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed_counter=0;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed=1;
            
        end
        function cb_pi_mep_plot_reset(obj)
            delete(obj.bst.info.handles.mean_mep_plot)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
            
        end
        function cb_pi_mep_save_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt=obj.pi.mep.save_plt.Value;
        end
        
        
        function pause(obj)
            obj.info.pause=obj.info.pause+1;
            if bitget(obj.info.pause,1) %odd
                obj.pi.pause.String='Unpause';
                uiwait
            else %even
                
                uiresume
                obj.pi.pause.String='Pause';
            end
            
        end
        %% hotspot section
        function pi_hotspot(obj)
            obj.pi.hotspot.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Hotspot Search' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.hotspot.vb = uix.VBox( 'Parent', obj.pi.hotspot.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.hotspot.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_input_device); %,'Callback',@obj.cb_hotspot_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.hotspot.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_hotspot_input_device); %,'Callback',@obj.cb_hotspot_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_output_device); %,'Callback',@obj.cb_hotspot_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.hotspot.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_output_device); %,'Callback',@obj.cb_hotspot_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_target_muscle); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            
            % row 2g
            mep_panel_row2g = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_display_scopes); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2g, 'Widths', [150 -2]);
            
            
            
            % %             % row 3
            % %             mep_panel_row3 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            % %             uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            % %             obj.pi.hotspot.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_stimulation_intensities);
            % %             set( mep_panel_row3, 'Widths', [150 -2]);
            % %
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No. of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_hotspot_mep_onset);
            obj.pi.hotspot.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %             %row 9
            %             mep_panel_row10 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_prestim_scope_ext);
            %             obj.pi.hotspot.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_poststim_scope_ext);
            %             set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_hotspot_prestim_scope_plt);
            obj.pi.hotspot.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_hotspot_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            
            %             % row 15
            %             mep_panel_15 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_hotspot_ylim_min);
            %             obj.pi.hotspot.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_hotspot_ylim_max);
            %             set( mep_panel_15, 'Widths', [150 -2 -2]);
            %
            %
            %             % row 14
            %             mep_panel_14 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_hotspot_FontSize);
            %             set( mep_panel_14, 'Widths', [150 -2]);
            %
            %             % row 15
            %             mep_panel_15 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_15,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_hotspot_trials_for_mean_annotation);
            %             obj.pi.hotspot.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_hotspot_trials_reset);
            %             obj.pi.hotspot.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean Plot','Callback',@(~,~)obj.cb_pi_hotspot_plot_reset);
            %
            %             set( mep_panel_15, 'Widths', [150 -1 -2 -2]);
            %
            %             % row 16
            %             mep_panel_16 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_16,'String','Save Plot:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.hotspot.save_plt=uicontrol( 'Style','checkbox','Parent', mep_panel_16 ,'FontSize',11,'Value',obj.info.defaults.save_plt,'Callback',@(~,~)obj.cb_pi_hotspot_save_plt);
            %             set( mep_panel_16, 'Widths', [-2 -2]);
            %
            uiextras.HBox( 'Parent', obj.pi.hotspot.vb);
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.hotspot.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_hotspot_update);
            obj.pi.hotspot.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_hotspot_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.best_stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            
            
            
            set(obj.pi.hotspot.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -2 -0.5])
            
            
        end
        function default_par_hotspot(obj)
            
            obj.info.defaults.input_device=1;
            obj.info.defaults.output_device=1;
            obj.info.defaults.display_scopes='';
            
            obj.info.defaults.target_muscle='';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            obj.info.defaults.trials_per_condition=[1000];
            obj.info.defaults.iti=[4 6];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=50;
            obj.info.defaults.poststim_scope_plt=150;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+5000;
            obj.info.defaults.ylim_min=-5000;
            obj.info.defaults.FontSize=14;
            obj.info.defaults.mt_mv=0.05;
            obj.info.defaults.thresholding_method=1;
            obj.info.defaults.trials_to_avg=10;
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
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_hotspot_par(obj)
            
            obj.pi.hotspot.input_device.Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device;
            obj.pi.hotspot.output_device.Value= obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device;
            obj.pi.hotspot.display_scopes.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes;
            
            obj.pi.hotspot.target_muscle.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.pi.hotspot.stimulation_intensities.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            obj.pi.hotspot.trials_per_condition.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.pi.hotspot.iti.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.hotspot.mep_onset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset;
            obj.pi.hotspot.mep_offset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset;
            obj.pi.hotspot.prestim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext);
            obj.pi.hotspot.poststim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext);
            obj.pi.hotspot.prestim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt);
            obj.pi.hotspot.poststim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt);
            obj.pi.hotspot.ylim_max.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.pi.hotspot.ylim_min.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.pi.hotspot.FontSize.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.pi.hotspot.trials_for_mean_annotation.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation);
            
            obj.pi.hotspot.run.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable;
            obj.pi.hotspot.target_muscle.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable;
            obj.pi.hotspot.prestim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable;
            obj.pi.hotspot.poststim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable;
            
            
        end
        function cb_pi_hotspot_run(obj)
            obj.bst.inputs.measure_str=cellstr('Motor Hotspot Search');
            obj.bst.inputs.input_device=obj.pi.hotspot.input_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device));
            obj.bst.inputs.output_device=obj.pi.hotspot.output_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device));
            obj.bst.inputs.target_muscle=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.bst.inputs.display_scopes=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes);
            obj.bst.inputs.stimuli=num2cell(NaN);
            if(numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)==1 || numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)>2)
                obj.bst.inputs.iti=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
                disp 1stcommand
            else
                %                 obj.bst.inputs.iti=cellstr(num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti));
                obj.bst.inputs.iti={num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)};
                
                disp 2ndcommand
            end
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.trials=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.ylimMax=500;
            obj.bst.inputs.ylimMin=-500;
            obj.bst.best_hotspot;
            
            
            % % % %             OLD SCRIPT
            % % % %
            % % % % %             obj.disable_listboxes
            % % % %             delete(obj.pr.mep.axes1)
            % % % %             delete(obj.pr.hotspot.axes1)
            % % % %             delete(obj.pr.mt.axes_mep)
            % % % %             delete(obj.pr.mt.axes_mtplot)
            % % % %             delete(obj.pr.ioc.axes_mep)
            % % % %             delete(obj.pr.ioc.axes_scatplot)
            % % % %             delete(obj.pr.ioc.axes_fitplot)
            % % % %
            % % % %
            % % % %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            % % % %             obj.pi.hotspot.run.Enable='on';
            % % % %             obj.pi.hotspot.target_muscle.Enable='off';
            % % % % %             obj.pi.hotspot.prestim_scope_ext.Enable='off';
            % % % % %             obj.pi.hotspot.poststim_scope_ext.Enable='off';
            % % % %
            % % % %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.hotspot.run.Enable;
            % % % %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.hotspot.target_muscle.Enable;
            % % % % %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.hotspot.prestim_scope_ext.Enable;
            % % % % %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.hotspot.poststim_scope_ext.Enable;
            % % % %
            % % % %             obj.bst.inputs.current_session=obj.info.event.current_session;
            % % % %             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            % % % %             %             obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            % % % %             obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            % % % %             obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            % % % %             obj.bst.inputs.stim_mode='MSO';
            % % % %             obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            % % % %             obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            % % % % %             obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            % % % % %             obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            % % % %             obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            % % % %             obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            % % % % %             obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            % % % % %             obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            % % % % %             obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            % % % % %             obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            % % % %
            % % % % %             obj.bst.inputs.reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).reset_pressed;
            % % % % %             obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            % % % %
            % % % % %             obj.pr_hotspot;
            % % % % %
            % % % % %             %             try
            % % % % %             obj.cb_menu_save;
            % % % % %             obj.bst.best_motorhotspot;
            % % % % %             %             catch
            % % % % %             %                 disp('MEP Measurement Stopped | BEST Toolbox')
            % % % % %             %             end
            % % % % %             obj.cb_menu_save;
            % % % % %             delete(sprintf('%s.mat',obj.bst.info.save_str_runtime));
            % % % % %
            % % % % %
            % % % % %             if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt==1)
            % % % % %                 exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            % % % % %                 sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            % % % % %                 sess=obj.info.event.current_session;
            % % % % %                 meas=obj.info.event.current_measure_fullstr;
            % % % % %                 plt='MEP_Plot';
            % % % % %                 timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            % % % % %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            % % % % %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            % % % % %                 copyobj(obj.pr.hotspot.axes1,figg)
            % % % % %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            % % % % %                 saveas(figg,file_name,'fig');
            % % % % %                 close(figg)
            % % % % %             end
            % % % % %             obj.enable_listboxes
        end
        function cb_pi_hotspot_update(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx+1;
            str1=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx);
            str2='update_';
            str=[str2 str1];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).(str)=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement);
            % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=[];
            % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials=[];
            % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).rawdata=[];
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            
            obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=obj.bst.inputs;
            obj.bst.best_trialprep;
            
            %% Font updating
            obj.bst.info.axes.mep
            obj.bst.info.axes.mep.FontSize=obj.bst.inputs.FontSize;
            %% Graph Y lim setting
            set(obj.bst.info.axes.mep,'YLim',[obj.bst.inputs.ylim_min obj.bst.inputs.ylim_max])
            y_ticks_mep=linspace(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_min,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_max,5);
            yticks(y_ticks_mep);
            
            %% Graph X lim setting
            xlim([obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(1), obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)]);
            
            
            %% MEP search window setting
            delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
            mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
            mat=unique(sort([mat1 mat2]));
            mat=unique(mat);
            xticks(mat);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):0.25:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
        end
        function cb_pi_hotspot_input_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device=obj.pi.hotspot.input_device.Value;
            obj.pi.hotspot.input_device.Value
            obj.pi.hotspot.input_device.String
            obj.pi.hotspot.input_device.Value
        end
        function cb_pi_hotspot_output_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device=obj.pi.hotspot.output_device.Value;
            obj.pi.hotspot.output_device.Value
        end
        function cb_pi_hotspot_display_scopes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=obj.pi.hotspot.display_scopes.String;
            % %             %first evalute
            % %             if(ischar(obj.pi.mep.display_scopes.String) || (iscell(eval(obj.pi.mep.display_scopes.String))))
            % %                 if(iscell(eval(obj.pi.mep.display_scopes.String)))
            % %                     cellarraysize=size(eval(obj.pi.mep.display_scopes.String))
            % %                     if(cellarraysize(1)>1)
            % %                         %error dialogue
            % %                         disp BEST Toolbox: The Display Scopes input field must be a 1 x n dimension cell array
            % %                     end
            % %                 end
            % %                 try
            % %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=eval(obj.pi.mep.display_scopes.String);
            % %                     obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes
            % %                 catch
            % %                     disp BEST Toolbox: The Display Scopes field input can only be a Character or Cell array OR no such variable exists with this name in the MATLAB workspace
            % %                 end
            % %                 %             elseif (iscell(eval(obj.pi.mep.display_scopes.String)))
            % %                 %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=eval(obj.pi.mep.display_scopes.String);
            % %                 %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes
            % %             else
            % %                 % display error dialogue
            % %                 disp BEST Toolbox: The Display Scopes field input can only be a Character or Cell array
            % %             end
        end
        function cb_pi_hotspot_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.hotspot.target_muscle.String;
        end
        function cb_pi_hotspot_stimulation_intensities(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=str2num(obj.pi.hotspot.stimulation_intensities.String);
        end
        function cb_pi_hotspot_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=str2num(obj.pi.hotspot.trials_per_condition.String);
        end
        function cb_pi_hotspot_iti(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.hotspot.iti.String);
        end
        function cb_pi_hotspot_mep_onset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset=str2num(obj.pi.hotspot.mep_onset.String);
        end
        function cb_pi_hotspot_mep_offset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset=str2num(obj.pi.hotspot.mep_offset.String);
        end
        function cb_pi_hotspot_prestim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext=str2num(obj.pi.hotspot.prestim_scope_ext.String);
        end
        function cb_pi_hotspot_poststim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext=str2num(obj.pi.hotspot.poststim_scope_ext.String);
        end
        function cb_pi_hotspot_prestim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt=str2num(obj.pi.hotspot.prestim_scope_plt.String);
        end
        function cb_pi_hotspot_poststim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt=str2num(obj.pi.hotspot.poststim_scope_plt.String);
        end
        function cb_pi_hotspot_ylim_min(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min=str2num(obj.pi.hotspot.ylim_min.String);
        end
        function cb_pi_hotspot_ylim_max(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max=str2num(obj.pi.hotspot.ylim_max.String);
        end
        function cb_pi_hotspot_FontSize(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize=str2num(obj.pi.hotspot.FontSize.String);
        end
        function cb_pi_hotspot_trials_for_mean_annotation(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation=str2num(obj.pi.hotspot.trials_for_mean_annotation.String);
        end
        function cb_pi_hotspot_trials_reset(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed_counter=0;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed=1;
            
        end
        function cb_pi_hotspot_plot_reset(obj)
            delete(obj.bst.info.handles.mean_mep_plot)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
        end
        function cb_pi_hotspot_save_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt=obj.pi.hotspot.save_plt.Value;
        end
        
        
        %% ioc section
        function pi_ioc(obj)
            main
            function main
                %make the pi ioc sp complete first
                obj.pi.ioc.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','MEP IOC' ,'FontWeight','Bold','TitlePosition','centertop');
                obj.pi.ioc.vb = uix.VBox( 'Parent', obj.pi.ioc.panel, 'Spacing', 5, 'Padding', 5  );

                
                mep_panel_row1a = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row1a,'String','Stimulation Mode:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.stim_mode=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1a ,'FontSize',11,'String',{'Single Pulse','Paired Pulse'},'Tag','stim_mode','Callback',@cb_stim_mode); %,'Callback',@obj.cb_ioc_target_muscle
                set( mep_panel_row1a, 'Widths', [150 -2]);
                
                mep_panel_row1b = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row1b,'String','Brain State:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.brain_state=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1b ,'FontSize',11,'String',{'Independent','Dependent'},'Tag','stim_mode','Callback',@cb_stim_mode); %,'Callback',@obj.cb_ioc_target_muscle
                set( mep_panel_row1b, 'Widths', [150 -2]);
                
                
                mep_panel_row2 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                str_in_device(1)= (cellstr('Select'));
                str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
                
                obj.pi.ioc.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_ioc_input_device); %,'Callback',@obj.cb_ioc_target_muscle
                
                set( mep_panel_row2, 'Widths', [150 -2]);
                
                % row 2f
                mep_panel_row2f = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                %             obj.pi.ioc.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_output_device); %,'Callback',@obj.cb_ioc_target_muscle
                str_out_device(1)= (cellstr('Select'));
                str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
                obj.pi.ioc.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_output_device); %,'Callback',@obj.cb_ioc_target_muscle
                
                set( mep_panel_row2f, 'Widths', [150 -2]);
                
                % row 2
                mep_panel_row2 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_target_muscle); %,'Callback',@obj.cb_ioc_target_muscle
                set( mep_panel_row2, 'Widths', [150 -2]);
                
                
                % row 2g
                mep_panel_row2g = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_display_scopes); %,'Callback',@obj.cb_ioc_target_muscle
                set( mep_panel_row2g, 'Widths', [150 -2]);
                
                % row 4
                mep_panel_row4 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_trials_per_condition);
                set( mep_panel_row4, 'Widths', [150 -2]);
                
                %row 5
                mep_panel_row5 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_iti);
                set( mep_panel_row5, 'Widths', [150 -2]);
                
                stim_mode=uix.Panel( 'Parent', obj.pi.ioc.vb,'Padding',0,'Units','normalized','BorderType','none');
                cb_stim_mode(stim_mode);
                mep_panel_17 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                obj.pi.ioc.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_ioc_update);
                obj.pi.ioc.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_ioc_run);
                obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
                obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
                set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);

                set(obj.pi.ioc.vb,'Heights',[-0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -4 -0.5])
                
            end
            function cb_stim_mode(stim_mode)
                obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stim_mode=char(obj.pi.ioc.stim_mode.String(obj.pi.ioc.stim_mode.Value));
                switch obj.pi.ioc.stim_mode.Value
                    case 1 % Single Pulse
                        cb_pi_ioc_single_pulse(stim_mode)
                    case 2 % Paired Pulse
                        cb_pi_ioc_paired_pulse
                end
            end
            function cb_pi_ioc_single_pulse(stim_mode)
                stimModvBox=uix.VBox( 'Parent', stim_mode, 'Spacing', 0, 'Padding', 0  );
                % row 3
                mep_panel_row3 = uix.HBox( 'Parent', stimModvBox, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_stimulation_intensities);
                set( mep_panel_row3, 'Widths', [150 -2]);
                
                % row 12
                mep_panel_row12 = uix.HBox( 'Parent', stimModvBox, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_ioc_units_mso);
                obj.pi.ioc.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_ioc_units_mt);
                set( mep_panel_row12, 'Widths', [200 -2 -2]);

                
                mep_panel_13 = uix.HBox( 'Parent', stimModvBox, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_mt);
                mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
                mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
                mt_btn_listbox_str=['Select' mt_btn_listbox_str];
                obj.pi.ioc.mt_btn=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',mt_btn_listbox_str,'Callback',@(~,~)obj.cb_pi_ioc_mt_btn);
                set( mep_panel_13, 'Widths', [175 -2 -2]);
                

                %row 8
                mep_panel_row8 = uix.HBox( 'Parent', stimModvBox, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_ioc_mep_onset);
                obj.pi.ioc.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_mep_offset);
                set( mep_panel_row8, 'Widths', [150 -2 -2]);
                
                
                %             %row 9
                %             mep_panel_row10 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
                %             uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                %             obj.pi.ioc.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_prestim_scope_ext);
                %             obj.pi.ioc.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_poststim_scope_ext);
                %             set( mep_panel_row10, 'Widths', [150 -2 -2]);
                %
                %row 11
                mep_panel_row11 = uix.HBox( 'Parent', stimModvBox, 'Spacing', 5, 'Padding', 5  );
                uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
                obj.pi.ioc.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_prestim_scope_plt);
                obj.pi.ioc.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_poststim_scope_plt);
                set( mep_panel_row11, 'Widths', [150 -2 -2]);
                
                uiextras.HBox( 'Parent', stimModvBox,'Spacing', 5, 'Padding', 5 )

                set( stimModvBox,'Heights',[-0.4 -0.4 -0.4 -0.4 -0.4 -2])
            end
            function cb_pi_ioc_paired_pulse
            end
            
            function cb_par_saving(source,~)
                if(strcmp(source.Tag,'stim_mode'))
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=char(source.String(source.Value));
                else
                    obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).(source.Tag)=source.String;
                end
                
            end
            
        end
        function default_par_ioc(obj)
            obj.info.defaults.input_device=1;
            obj.info.defaults.output_device=1;
            obj.info.defaults.display_scopes='';
            obj.info.defaults.target_muscle='';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            obj.info.defaults.trials_per_condition=[15];
            obj.info.defaults.iti=[4 6];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=20;
            obj.info.defaults.poststim_scope_plt=100;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+5000;
            obj.info.defaults.ylim_min=-5000;
            obj.info.defaults.FontSize=14;
            obj.info.defaults.mt_mv=0.05;
            obj.info.defaults.thresholding_method=2;
            obj.info.defaults.trials_to_avg=15;
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
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_ioc_par(obj)
            obj.pi.ioc.input_device.Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device;
            obj.pi.ioc.output_device.Value= obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device;
            obj.pi.ioc.display_scopes.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes;
            obj.pi.ioc.target_muscle.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.pi.ioc.stimulation_intensities.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            obj.pi.ioc.trials_per_condition.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.pi.ioc.iti.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.ioc.mep_onset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset;
            obj.pi.ioc.mep_offset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset;
            obj.pi.ioc.prestim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext);
            obj.pi.ioc.poststim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext);
            obj.pi.ioc.prestim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt);
            obj.pi.ioc.poststim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt);
            obj.pi.ioc.units_mso.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso);
            obj.pi.ioc.units_mt.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt);
            obj.pi.ioc.mt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt);
            %             obj.pi.ioc.mt_btn.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn);
            obj.pi.ioc.ylim_max.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.pi.ioc.ylim_min.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.pi.ioc.FontSize.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.pi.ioc.trials_for_mean_annotation.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation);
            
            obj.pi.ioc.run.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable;
            obj.pi.ioc.target_muscle.Enable= obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable;
            obj.pi.ioc.units_mso.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable;
            obj.pi.ioc.units_mt.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable;
            obj.pi.ioc.mt.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable;
            obj.pi.ioc.mt_btn.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable;
            obj.pi.ioc.prestim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable;
            obj.pi.ioc.poststim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable;
            obj.pi.ioc.trials_per_condition.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable;
            obj.pi.ioc.stimulation_intensities.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable;
        end
        function cb_pi_ioc_run(obj)
            
            obj.bst.inputs.measure_str=cellstr('IOC');
            obj.bst.inputs.input_device=obj.pi.ioc.input_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device));
            obj.bst.inputs.output_device=obj.pi.ioc.output_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device));
            obj.bst.inputs.target_muscle=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.bst.inputs.display_scopes=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes);
            obj.bst.inputs.stimuli=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            if(numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)==1 || numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)>2)
                obj.bst.inputs.iti=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            else
                obj.bst.inputs.iti={num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)};
            end
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.trials=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.ylimMax=5000;
            obj.bst.inputs.ylimMin=-5000;
            obj.bst.best_ioc;
            % best_ioc
            
            
            %             OLD SCRIPT
            %             obj.disable_listboxes
            %             delete(obj.pr.mep.axes1)
            %             delete(obj.pr.hotspot.axes1)
            %             delete(obj.pr.mt.axes_mep)
            %             delete(obj.pr.mt.axes_mtplot)
            %             delete(obj.pr.ioc.axes_mep)
            %             delete(obj.pr.ioc.axes_scatplot)
            %             delete(obj.pr.ioc.axes_fitplot)
            %
            %
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            %             obj.pi.ioc.run.Enable='off';
            %             obj.pi.ioc.target_muscle.Enable='off';
            %             obj.pi.ioc.units_mso.Enable='off';
            %             obj.pi.ioc.units_mt.Enable='off';
            %             obj.pi.ioc.mt.Enable='off';
            %             obj.pi.ioc.mt_btn.Enable='off';
            %             obj.pi.ioc.iti.Enable='off';
            %             obj.pi.ioc.trials_per_condition.Enable='off';
            %             obj.pi.ioc.stimulation_intensities.Enable='off';
            %             obj.pi.ioc.prestim_scope_ext.Enable='off';
            %             obj.pi.ioc.poststim_scope_ext.Enable='off';
            %
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.ioc.run.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.ioc.target_muscle.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_msoEnable=obj.pi.ioc.units_mso.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mtEnable=obj.pi.ioc.units_mt.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mtEnable=obj.pi.ioc.mt.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btnEnable=obj.pi.ioc.mt_btn.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.ioc.prestim_scope_ext.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.ioc.poststim_scope_ext.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable=obj.pi.ioc.trials_per_condition.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensitiesEnable=obj.pi.ioc.stimulation_intensities.Enable;
            %
            %             obj.bst.inputs.current_session=obj.info.event.current_session;
            %             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %             obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            %             obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            %             obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            %             if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso==1)
            %                 obj.bst.inputs.stim_mode='MSO';
            %             else
            %                 obj.bst.inputs.stim_mode='MT';
            %                 obj.bst.inputs.mt_mso=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt;
            %             end
            %             obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            %             obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            %             obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            %             obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            %             obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            %             obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            %             obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            %             obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            %             obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            %             obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            %
            %             obj.bst.inputs.reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).reset_pressed;
            %             obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            %
            %             obj.pr_ioc;
            %             obj.cb_menu_save;
            %             obj.bst.best_ioc;
            %             obj.cb_menu_save;
            %             delete(sprintf('%s.mat',obj.bst.info.save_str_runtime));
            %
            %             if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt==1)
            %                 exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            %                 sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            %                 sess=obj.info.event.current_session;
            %                 meas=obj.info.event.current_measure_fullstr;
            %                 plt='MEP_Plot';
            %                 timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.ioc.axes_mep,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %
            %                 plt='Scatter_Plot';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.ioc.axes_scatplot,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %
            %                 plt='FittedIOC_Plot';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.ioc.axes_fitplot,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %             end
            %             obj.enable_listboxes
            
        end
        function cb_pi_ioc_update(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            
            obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=obj.bst.inputs;
            
            %% scope extraction preperation
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_samples=((obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_ext)+(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_ext))*5;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples=(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_ext)*(-5);
            
            %% scope plotting preperation
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_last=(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt)*5;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_first=(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt)*(5);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_total=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_last+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_first;
            %% making time vector
            mep_plot_time_vector=1:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_total
            mep_plot_time_vector=mep_plot_time_vector./obj.bst.inputs.sc_samplingrate
            mep_plot_time_vector=mep_plot_time_vector*1000
            mep_plot_time_vector=mep_plot_time_vector+(((-1)*obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_first)/(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.sc_samplingrate)*1000)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector=mep_plot_time_vector
            
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_first=((obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)*-1)-obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_first;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_last=((obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)*-1)+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_plot_last;
            
            
            % onset offset MEP Amps
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_calib=obj.bst.inputs.mep_onset*5000;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_calib=obj.bst.inputs.mep_offset*5000;
            
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_samp=abs(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_calib;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_samp=abs(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_calib;
            
            %% Font updating
            obj.bst.info.axes.mep
            obj.bst.info.axes.mep.FontSize=obj.bst.inputs.FontSize;
            %% Graph Y lim setting
            set(obj.bst.info.axes.mep,'YLim',[obj.bst.inputs.ylim_min obj.bst.inputs.ylim_max])
            y_ticks_mep=linspace(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_min,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_max,5);
            yticks(obj.bst.info.axes.mep,y_ticks_mep);
            
            %% Graph X lim setting
            xlim(obj.bst.info.axes.mep,[obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(1), obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)]);
            
            
            %% MEP search window setting
            delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
            mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
            mat=unique(sort([mat1 mat2]));
            mat=unique(mat);
            xticks(obj.bst.info.axes.mep,mat);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):0.25:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
        end
        function cb_pi_ioc_input_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device=obj.pi.ioc.input_device.Value;
            obj.pi.ioc.input_device.Value
            obj.pi.ioc.input_device.String
            obj.pi.ioc.input_device.Value
        end
        function cb_pi_ioc_output_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device=obj.pi.ioc.output_device.Value;
            obj.pi.ioc.output_device.Value
        end
        function cb_pi_ioc_display_scopes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=obj.pi.ioc.display_scopes.String;
            
        end
        function cb_pi_ioc_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.ioc.target_muscle.String;
        end
        function cb_pi_ioc_stimulation_intensities(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=str2num(obj.pi.ioc.stimulation_intensities.String);
        end
        function cb_pi_ioc_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=str2num(obj.pi.ioc.trials_per_condition.String);
        end
        function cb_pi_ioc_iti(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.ioc.iti.String);
        end
        function cb_pi_ioc_mep_onset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset=str2num(obj.pi.ioc.mep_onset.String);
        end
        function cb_pi_ioc_mep_offset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset=str2num(obj.pi.ioc.mep_offset.String);
        end
        function cb_pi_ioc_prestim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext=str2num(obj.pi.ioc.prestim_scope_ext.String);
        end
        function cb_pi_ioc_poststim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext=str2num(obj.pi.ioc.poststim_scope_ext.String);
        end
        function cb_pi_ioc_prestim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt=str2num(obj.pi.ioc.prestim_scope_plt.String);
        end
        function cb_pi_ioc_poststim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt=str2num(obj.pi.ioc.poststim_scope_plt.String);
        end
        function cb_pi_ioc_units_mso(obj)
            if(obj.pi.ioc.units_mso.Value==1)
                obj.pi.ioc.units_mt.Value=0;
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=(obj.pi.ioc.units_mso.Value);
        end
        function cb_pi_ioc_units_mt(obj)
            if(obj.pi.ioc.units_mt.Value==1)
                obj.pi.ioc.units_mso.Value=0;
            end
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt=(obj.pi.ioc.units_mt.Value);
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=0;
        end
        function cb_pi_ioc_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt=str2num(obj.pi.ioc.mt.String);
        end
        function cb_pi_ioc_mt_btn(obj)
            %                         obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=(obj.pi.ioc.mt_btn.String);
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=(obj.pi.ioc.mt_btn);
            meas=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.String(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.Value);
            meas=meas{1}
            meas(meas == ' ') = '_';
            if(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn.Value>1)
                try
                    obj.pi.ioc.mt.String= obj.bst.sessions.(obj.info.event.current_session).(meas).results.mt
                catch
                    obj.pi.ioc.mt.String=[];
                end
            else
                obj.pi.ioc.mt.String=[];
            end
            obj.cb_pi_ioc_mt;
        end
        function cb_pi_ioc_ylim_min(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min=str2num(obj.pi.ioc.ylim_min.String);
        end
        function cb_pi_ioc_ylim_max(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max=str2num(obj.pi.ioc.ylim_max.String);
        end
        function cb_pi_ioc_FontSize(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize=str2num(obj.pi.ioc.FontSize.String);
        end
        function cb_pi_ioc_trials_for_mean_annotation(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation=str2num(obj.pi.ioc.trials_for_mean_annotation.String);
        end
        function cb_pi_ioc_trials_reset(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed_counter=0;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed=1;
        end
        function cb_pi_ioc_plot_reset(obj)
            delete(obj.bst.info.handles.mean_mep_plot)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
        end
        function cb_pi_ioc_save_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt=obj.pi.ioc.save_plt.Value;
        end
        
        
        %% threshold section
        function pi_mt(obj)
            obj.pi.mt.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Threshold Hunting' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mt.vb = uix.VBox( 'Parent', obj.pi.mt.panel, 'Spacing', 5, 'Padding', 5  );
            
            %             % row 1
            %             uiextras.HBox( 'Parent', obj.pi.mt.vb,'Spacing', 5, 'Padding', 5 )
            %             mep_panel_row1 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Thresholding Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt.thresholding_method=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'PEST Pentland', 'PEST Taylor'},'Callback',@(~,~)obj.cb_pi_mt_thresholding_method);
            %             set( mep_panel_row1, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_input_device); %,'Callback',@obj.cb_mt_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.mt.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_mt_input_device); %,'Callback',@obj.cb_mt_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_output_device); %,'Callback',@obj.cb_mt_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.mt.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_output_device); %,'Callback',@obj.cb_mt_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2g
            mep_panel_row2g = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display EMG Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_display_scopes); %,'Callback',@obj.cb_mt_target_muscle
            set( mep_panel_row2g, 'Widths', [150 -2]);
            %
            
            %             % row 2
            %             mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_target_muscle); %,'Callback',@obj.cb_mt_target_muscle
            %             set( mep_panel_row2, 'Widths', [150 -2]);
            %
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Motor Threshold (mV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.mt_mv=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_mt_mv);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            % row c
            mep_panel_rowC = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_rowC,'String','No. of Trials to Avg:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.trials_to_avg=uicontrol( 'Style','edit','Parent', mep_panel_rowC ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_trials_to_avg);
            set( mep_panel_rowC, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.mt.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.mt.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_mt_mep_onset);
            obj.pi.mt.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %row 9
            mep_panel_row10 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_prestim_scope_ext);
            obj.pi.mt.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_poststim_scope_ext);
            set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mt_prestim_scope_plt);
            obj.pi.mt.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mt_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mt_ylim_min);
            obj.pi.mt.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mt_ylim_max);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_mt_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
            
            
            % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_mt_trials_for_mean_annotation);
            obj.pi.mt.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_mt_trials_reset);
            obj.pi.mt.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Mean Plot','Callback',@(~,~)obj.cb_pi_mt_plot_reset);
            
            set( mep_panel_16, 'Widths', [150 -1 -2 -2]);
            
            % row 18
            mep_panel_18 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_18,'String','Save Plot:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.save_plt=uicontrol( 'Style','checkbox','Parent', mep_panel_18 ,'FontSize',11,'Value',obj.info.defaults.save_plt,'Callback',@(~,~)obj.cb_pi_mt_save_plt);
            set( mep_panel_18, 'Widths', [-2 -2]);
            
            % row 19
            mep_panel_19 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_19,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.result_mt=uicontrol( 'Style','edit','Enable','off','Parent', mep_panel_19 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_result_mt);
            set( mep_panel_19, 'Widths', [-2 -2]);
            
            
            
            uiextras.HBox( 'Parent', obj.pi.mt.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mt.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_update);
            obj.pi.mt.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mt.vb,'Heights',[-0.01 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.01 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.5])
            
            
        end
        function default_par_mt(obj)
            obj.info.defaults.target_muscle='APBr';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            obj.info.defaults.trials_per_condition=[50];
            obj.info.defaults.iti=[4 6];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=20;
            obj.info.defaults.poststim_scope_plt=100;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+5000;
            obj.info.defaults.ylim_min=-5000;
            obj.info.defaults.FontSize=14;
            obj.info.defaults.mt_mv=0.05;
            obj.info.defaults.thresholding_method=2;
            obj.info.defaults.trials_to_avg=15;
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
            obj.info.defaults.result_mt=[];
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
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        
        function func_load_mt_par(obj)
            obj.pi.mt.thresholding_method.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_method);
            obj.pi.mt.target_muscle.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.pi.mt.mt_mv.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv);
            obj.pi.mt.trials_per_condition.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.pi.mt.trials_to_avg.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg);
            obj.pi.mt.iti.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.mt.mep_onset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset;
            obj.pi.mt.mep_offset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset;
            obj.pi.mt.prestim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext);
            obj.pi.mt.poststim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext);
            obj.pi.mt.prestim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt);
            obj.pi.mt.poststim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt);
            obj.pi.mt.ylim_max.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.pi.mt.ylim_min.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.pi.mt.FontSize.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.pi.mt.trials_for_mean_annotation.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation);
            obj.pi.mt.result_mt=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).result_mt);
            
            obj.pi.mep.run.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable;
            obj.pi.mep.target_muscle.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable;
            obj.pi.mt.trials_per_condition.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt.trials_per_conditionEnable;
            obj.pi.mep.mt_mv.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mvEnable;
            obj.pi.mep.thresholding_method.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_methodEnable;
            obj.pi.mep.prestim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable;
            obj.pi.mep.poststim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable;
            
            
        end
        
        function cb_pi_mt_run(obj)
            obj.disable_listboxes
            delete(obj.pr.mep.axes1)
            delete(obj.pr.hotspot.axes1)
            delete(obj.pr.mt.axes_mep)
            delete(obj.pr.mt.axes_mtplot)
            delete(obj.pr.ioc.axes_mep)
            delete(obj.pr.ioc.axes_scatplot)
            delete(obj.pr.ioc.axes_fitplot)
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            obj.pi.mt.thresholding_method.Enable='off';
            obj.pi.mt.mt_mv.Enable='off';
            obj.pi.mt.run.Enable='off';
            obj.pi.mt.target_muscle.Enable='off';
            obj.pi.mt.trials_per_condition.Enable='off';
            obj.pi.mt.prestim_scope_ext.Enable='off';
            obj.pi.mt.poststim_scope_ext.Enable='off';
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.mep.run.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.mep.target_muscle.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt.trials_per_conditionEnable=obj.pi.mt.trials_per_condition.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mvEnable=obj.pi.mep.mt_mv.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_methodEnable=obj.pi.mep.thresholding_method.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.mep.prestim_scope_ext.Enable;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.mep.poststim_scope_ext.Enable;
            
            
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.motor_threshold=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv;
            obj.bst.inputs.mt_trialstoavg=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.stim_mode='MSO';
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            
            obj.bst.inputs.reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).reset_pressed;
            obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            
            obj.pr_mt;
            obj.cb_menu_save;
            
            %             try
            
            obj.bst.best_motorthreshold;
            obj.pi.mt.result_mt.String=obj.bst.sessions.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).results.mt;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stop_event=1;
            %             catch
            %                 disp('MEP Measurement Stopped | BEST Toolbox')
            %             end
            obj.cb_menu_save;
            
            delete(sprintf('%s.mat',obj.bst.info.save_str_runtime));
            if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt==1)
                exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
                sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
                sess=obj.info.event.current_session;
                meas=obj.info.event.current_measure_fullstr;
                plt='MEP_Plot';
                timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
                file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
                figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
                copyobj(obj.pr.mt.axes_mep,figg)
                set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
                saveas(figg,file_name,'fig');
                close(figg)
                
                plt='MotorThreshold_Plot';
                file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
                figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
                copyobj(obj.pr.mt.axes_mtplot,figg)
                set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
                saveas(figg,file_name,'fig');
                close(figg)
            end
            obj.enable_listboxes
        end
        function cb_pi_mt_update(obj)
            session=obj.info.event.current_session
            measure=obj.info.event.current_measure_fullstr
            % updating MT by updating no of trials to avg property
            
            obj.bst.sessions.(session).(measure).info.update_event=1;
            
            obj.bst.inputs.mt_trialstoavg=obj.par.(session).(measure).trials_to_avg;
            obj.bst.inputs.iti=(obj.par.(session).(measure).iti);
            obj.bst.inputs.mep_onset=(obj.par.(session).(measure).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(session).(measure).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(session).(measure).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(session).(measure).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(session).(measure).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(session).(measure).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(session).(measure).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(session).(measure).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(session).(measure).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(session).(measure).trials_for_mean_annotation;
            
            obj.bst.inputs.plot_reset_pressed=obj.par.(session).(measure).plot_reset_pressed;
            obj.bst.sessions.(session).(measure).inputs=obj.bst.inputs;
            
            %% scope extraction preperation
            obj.bst.sessions.(session).(measure).info.sc_ext_samples=((obj.bst.sessions.(session).(measure).inputs.prestim_scope_ext)+(obj.bst.sessions.(session).(measure).inputs.poststim_scope_ext))*5;
            obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples=(obj.bst.sessions.(session).(measure).inputs.prestim_scope_ext)*(-5);
            
            %% scope plotting preperation
            obj.bst.sessions.(session).(measure).info.sc_plot_last=(obj.bst.sessions.(session).(measure).inputs.poststim_scope_plt)*5;
            obj.bst.sessions.(session).(measure).info.sc_plot_first=(obj.bst.sessions.(session).(measure).inputs.prestim_scope_plt)*(5);
            obj.bst.sessions.(session).(measure).info.sc_plot_total=obj.bst.sessions.(session).(measure).info.sc_plot_last+obj.bst.sessions.(session).(measure).info.sc_plot_first;
            %% making time vector
            mep_plot_time_vector=1:obj.bst.sessions.(session).(measure).info.sc_plot_total;
            mep_plot_time_vector=mep_plot_time_vector./obj.bst.inputs.sc_samplingrate;
            mep_plot_time_vector=mep_plot_time_vector*1000;
            mep_plot_time_vector=mep_plot_time_vector+(((-1)*obj.bst.sessions.(session).(measure).info.sc_plot_first)/(obj.bst.sessions.(session).(measure).inputs.sc_samplingrate)*1000);
            obj.bst.sessions.(session).(measure).info.timevector=mep_plot_time_vector;
            
            obj.bst.sessions.(session).(measure).info.sc_plot_first=((obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)*-1)-obj.bst.sessions.(session).(measure).info.sc_plot_first;
            obj.bst.sessions.(session).(measure).info.sc_plot_last=((obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)*-1)+obj.bst.sessions.(session).(measure).info.sc_plot_last;
            
            
            if (length(obj.bst.inputs.iti)==2)
                jitter=(obj.bst.sessions.(session).(measure).inputs.iti(2)-obj.bst.sessions.(session).(measure).inputs.iti(1));
                iti=ones(1,obj.bst.sessions.(session).(measure).info.total_trials)*obj.bst.sessions.(session).(measure).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.bst.inputs.iti)==1)
                iti=ones(1,obj.bst.sessions.(session).(measure).info.total_trials)*(obj.bst.sessions.(session).(measure).inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.bst.sessions.(session).(measure).trials(:,2)=(round(iti,3))';
            obj.bst.sessions.(session).(measure).trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
            % onset offset MEP Amps
            obj.bst.sessions.(session).(measure).info.mep_onset_calib=obj.bst.inputs.mep_onset*5000;
            obj.bst.sessions.(session).(measure).info.mep_offset_calib=obj.bst.inputs.mep_offset*5000;
            
            obj.bst.sessions.(session).(measure).info.mep_onset_samp=abs(obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)+obj.bst.sessions.(session).(measure).info.mep_onset_calib;
            obj.bst.sessions.(session).(measure).info.mep_offset_samp=abs(obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)+obj.bst.sessions.(session).(measure).info.mep_offset_calib;
            if(obj.par.(session).(measure).stop_event==1)
                total_trials=obj.bst.sessions.(session).(measure).info.trial_plotted;
                obj.bst.sessions.(session).(measure).results.mt=ceil(mean(obj.bst.sessions.(session).(measure).trials((total_trials-(obj.bst.inputs.mt_trialstoavg-1):total_trials),1)));
                obj.bst.sessions.(session).(measure).info.rmt=obj.bst.sessions.(session).(measure).results.mt;
                total_trials=[];
                obj.pi.mt.result_mt.String=obj.bst.sessions.(session).(measure).results.mt;
                obj.par.(session).(measure).result_mt=obj.bst.sessions.(session).(measure).results.mt;
                
            end
            
            
        end
        
        
        
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
            obj.pi.tmsfmri.totalvolumes=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_totalvolumes);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (volumes):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.volumes_cond=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_volumes_cond);
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
            obj.pi.tmsfmri.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Enable','off','Callback',@(~,~)obj.cb_pi_tmsfmri_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
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
            
            set(obj.pi.tmsfmri.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -1.5 -0.4 -0.5])
            
            
        end
        function pi_eegtms(obj)
            obj.pi.eegtms.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','EEG triggered Stimulation' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.eegtms.vb = uix.VBox( 'Parent', obj.pi.eegtms.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.eegtms.vb,'Spacing', 5, 'Padding', 5 )
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.eegtms.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_input_device); %,'Callback',@obj.cb_eegtms_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.eegtms.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_eegtms_input_device); %,'Callback',@obj.cb_eegtms_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.eegtms.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_output_device); %,'Callback',@obj.cb_eegtms_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.eegtms.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_output_device); %,'Callback',@obj.cb_eegtms_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            
            %             % row 2
            %             mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.eegtms.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_output_device); %,'Callback',@obj.cb_eegtms_target_muscle
            %             set( mep_panel_row2, 'Widths', [150 -2]);
            %
            %              % row 2
            %             mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.eegtms.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_input_device); %,'Callback',@obj.cb_eegtms_target_muscle
            %             set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.target_montage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_target_montage); %,'Callback',@obj.cb_eegtms_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Montage Weights:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.target_montage=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_target_montage); %,'Callback',@obj.cb_eegtms_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String',' Frequency Band(Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.freq_ist=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_eegtms_freq_ist);
            obj.pi.eegtms.fre1_2nd=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_eegtms_fre1_2nd);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Phase:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.target_phase=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_target_phase); %,'Callback',@obj.cb_eegtms_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Amp Distribution:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.amp_low=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_amp_low);
            obj.pi.eegtms.amp_hi=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_amp_hi);
            
            
            obj.pi.eegtms.amp_units=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',{'Select','Absolute','Percentile'},'Value',2','Callback',@(~,~)obj.cb_pi_eegtms_amp_units);
            set( mep_panel_13, 'Widths', [150 -2 -2 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Offset Samples:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.offset_samples=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_offset_samples); %,'Callback',@obj.cb_eegtms_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_stimulation_intensities);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','No. of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            
            
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','Phase Tolerance:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.phase_tolerance=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_eegtms_phase_tolerance);
            set( mep_panel_row8, 'Widths', [150 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_prestim_scope_plt);
            obj.pi.ioc.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',0);
            obj.pi.eegtms.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT');
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            %             %older row 13
            %             mep_panel_13 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.eegtms.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_eegtms_mt);
            %             obj.pi.eegtms.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Callback',@(~,~)obj.cb_pi_eegtms_mt_btn);
            %             set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MT):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.eegtms.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11);
            mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
            mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
            mt_btn_listbox_str=['Select' mt_btn_listbox_str];
            obj.pi.eegtms.mt_btn=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',mt_btn_listbox_str);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            
            
            
            
            
            uiextras.HBox( 'Parent', obj.pi.eegtms.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.eegtms.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.eegtms.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Enable','off');
            obj.pi.eegtms.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_eegtms_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','off');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','off');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.eegtms.vb,'Heights',[-0.01 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -1 -0.5])
            
            
        end
        function pi_erp(obj)
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','ERP Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            %             obj.pi.mep.panel=uix.ScrollingPanel( 'Parent', obj.pi.empty_panel,'Units','normalized');
            
            
            obj.pi.mep.vb = uix.VBox( 'Parent', obj.pi.mep.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mep.vb,'Spacing', 5, 'Padding', 5 );
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_input_device); %,'Callback',@obj.cb_mep_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.mep.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_mep_input_device); %,'Callback',@obj.cb_mep_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            %             % row 2f
            %             mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             %             obj.pi.mep.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            %             str_out_device(1)= (cellstr('Select'));
            %             str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            %             obj.pi.mep.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            %
            %             set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2g
            mep_panel_row2g = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display EEG Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_display_scopes); %,'Callback',@obj.cb_mep_target_muscle
            set( mep_panel_row2g, 'Widths', [150 -2]);
            
            %               % row 2
            %             mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Display EMG Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_target_muscle); %,'Callback',@obj.cb_mep_target_muscle
            %             set( mep_panel_row2, 'Widths', [150 -2]);
            
            %             % row 3
            %             mep_panel_row3 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_stimulation_intensities);
            %             set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.mep.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            
            %row 9
            mep_panel_row10 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Post Data Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_prestim_scope_ext);
            obj.pi.mep.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_poststim_scope_ext);
            set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Post Data Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mep_prestim_scope_plt);
            obj.pi.mep.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mep_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            %             % row 12
            %             mep_panel_row12 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_mep_units_mso);
            %             obj.pi.mep.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_mep_units_mt);
            %             set( mep_panel_row12, 'Widths', [200 -2 -2]);
            %
            %             % row 13
            %             mep_panel_13 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_mt);
            %             mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
            %             mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
            %             mt_btn_listbox_str=['Select' mt_btn_listbox_str];
            %             obj.pi.mep.mt_btn=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',mt_btn_listbox_str,'Callback',@(~,~)obj.cb_pi_mep_mt_btn);
            %             set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mep_ylim_min);
            obj.pi.mep.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mep_ylim_max);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_mep_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
            %             % row 15
            %             mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_15,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_mep_trials_for_mean_annotation);
            %             obj.pi.mep.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_mep_trials_reset);
            %             obj.pi.mep.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean Plot','Callback',@(~,~)obj.cb_pi_mep_plot_reset);
            %             set( mep_panel_15, 'Widths', [150 -1 -2 -2]);
            
            
            % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Save Plot:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.save_plt=uicontrol( 'Style','checkbox','Parent', mep_panel_16 ,'FontSize',11,'Value',1,'Callback',@(~,~)obj.cb_pi_mep_save_plt);
            set( mep_panel_16, 'Widths', [-2 -2]);
            
            
            
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mep.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_update)
            obj.pi.mep.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mep.vb,'Heights',[0 -0.4 -0.4 -0.4 -0.4 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.4])
            
            
        end
        function pi_tep(obj)
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','TEP Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            %             obj.pi.mep.panel=uix.ScrollingPanel( 'Parent', obj.pi.empty_panel,'Units','normalized');
            
            
            obj.pi.mep.vb = uix.VBox( 'Parent', obj.pi.mep.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mep.vb,'Spacing', 5, 'Padding', 5 );
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_input_device); %,'Callback',@obj.cb_mep_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.mep.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_mep_input_device); %,'Callback',@obj.cb_mep_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.mep.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2g
            mep_panel_row2g = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display EEG Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_display_scopes); %,'Callback',@obj.cb_mep_target_muscle
            set( mep_panel_row2g, 'Widths', [150 -2]);
            
            %               % row 2
            %             mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Display EMG Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_target_muscle); %,'Callback',@obj.cb_mep_target_muscle
            %             set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_stimulation_intensities);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.mep.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            %             %row 8
            %             mep_panel_row8 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_mep_mep_onset);
            %             obj.pi.mep.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_mep_offset);
            %             set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %row 9
            mep_panel_row10 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_prestim_scope_ext);
            obj.pi.mep.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_poststim_scope_ext);
            set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mep_prestim_scope_plt);
            obj.pi.mep.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mep_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_mep_units_mso);
            obj.pi.mep.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_mep_units_mt);
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_mt);
            mt_btn_listbox_str_id= find(strcmp(obj.data.(obj.info.event.current_session).info.measurement_str_original,'MEP Motor Threshold Hunting'));
            mt_btn_listbox_str=obj.data.(obj.info.event.current_session).info.measurement_str_to_listbox(mt_btn_listbox_str_id);
            mt_btn_listbox_str=['Select' mt_btn_listbox_str];
            obj.pi.mep.mt_btn=uicontrol( 'Style','popupmenu','Parent', mep_panel_13 ,'FontSize',11,'String',mt_btn_listbox_str,'Callback',@(~,~)obj.cb_pi_mep_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mep_ylim_min);
            obj.pi.mep.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mep_ylim_max);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_mep_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
            %             % row 15
            %             mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            %             uicontrol( 'Style','text','Parent', mep_panel_15,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_mep_trials_for_mean_annotation);
            %             obj.pi.mep.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_mep_trials_reset);
            %             obj.pi.mep.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean Plot','Callback',@(~,~)obj.cb_pi_mep_plot_reset);
            %             set( mep_panel_15, 'Widths', [150 -1 -2 -2]);
            
            
            % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Save Plot:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.save_plt=uicontrol( 'Style','checkbox','Parent', mep_panel_16 ,'FontSize',11,'Value',1,'Callback',@(~,~)obj.cb_pi_mep_save_plt);
            set( mep_panel_16, 'Widths', [-2 -2]);
            
            
            
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mep.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_update)
            obj.pi.mep.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mep.vb,'Heights',[0 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.4])
            
            
        end
        function pi_rtms_train(obj)
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','rTMS Interventions' ,'FontWeight','Bold','TitlePosition','centertop');
            
            
            obj.pi.mep.vb = uix.VBox( 'Parent', obj.pi.mep.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mep.vb,'Spacing', 5, 'Padding', 5 );
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.mep.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Intervention Type:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type_val=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',{'Trains','Bursts'},'Value',1,'Callback',@(~,~)obj.cb_pi_mep_itrv_type);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Pulse Frequency (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','No. of Pulses per Train:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row6 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row6,'String','No. of Trains:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row6 ,'FontSize',11);
            set( mep_panel_row6, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row7 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row7,'String','Stimulation Intensities (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row7 ,'FontSize',11);
            set( mep_panel_row7, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row7 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row7,'String','Inter Train Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row7 ,'FontSize',11);
            set( mep_panel_row7, 'Widths', [150 -2]);
            
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mep.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_update)
            obj.pi.mep.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mep.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -3 -0.4 ])
            
            
        end
        function pi_rtms_brust(obj)
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','rTMS Interventions' ,'FontWeight','Bold','TitlePosition','centertop');
            
            
            obj.pi.mep.vb = uix.VBox( 'Parent', obj.pi.mep.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mep.vb,'Spacing', 5, 'Padding', 5 );
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mep.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.mep.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_output_device); %,'Callback',@obj.cb_mep_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Intervention Type:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type_val=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',{'Trains','Bursts'},'Value',2,'Callback',@(~,~)obj.cb_pi_mep_itrv_type);
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            
            % row 2
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','No. of Pulses per Brust:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row6 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row6,'String','No. of Brusts:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row6 ,'FontSize',11);
            set( mep_panel_row6, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row7 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row7,'String','Stimulation Intensities (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row7 ,'FontSize',11);
            set( mep_panel_row7, 'Widths', [150 -2]);
            
            
            % row 2
            mep_panel_row7 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row7,'String','Inter Pulse Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.itrv_type=uicontrol( 'Style','edit','Parent', mep_panel_row7 ,'FontSize',11);
            set( mep_panel_row7, 'Widths', [150 -2]);
            
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mep.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_update)
            obj.pi.mep.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mep.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -4 -0.4 ])
            
            
        end
        
        function cb_pi_mep_itrv_type(obj)
            switch obj.pi.mep.itrv_type_val.Value
                case 1
                    obj.pi_rtms_train
                case 2
                    obj.pi_rtms_brust
            end
            
        end
        function cb_pi_rtms_eegdata(obj)
            [file,path] = uigetfile;
        end
        
        
        function pi_rseeg(obj)
            obj.pi.rtms.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','resting-state EEG Analysis' ,'FontWeight','Bold','TitlePosition','centertop');
            %             obj.pi.mep.panel=uix.ScrollingPanel( 'Parent', obj.pi.empty_panel,'Units','normalized');
            
            
            obj.pi.rtms.vb = uix.VBox( 'Parent', obj.pi.rtms.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.rtms.vb,'Spacing', 5, 'Padding', 5 );
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','EEG Dataset:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Parent', mep_panel_row2 ,'Style','PushButton','String','Attach','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_rtms_eegdata,'Enable','on');
            set(mep_panel_row2,'Widths',[150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Rereferncing:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11);
            set(mep_panel_row3,'Widths',[150 -2]);
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Reference Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11);
            set(mep_panel_row4,'Widths',[150 -2]);
            % row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Montage Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set(mep_panel_row5,'Widths',[150 -2]);
            
            % row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Target Channel:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11);
            set(mep_panel_row5,'Widths',[150 -2]);
            
            % row 6
            mep_panel_row6 = uix.HBox( 'Parent', obj.pi.rtms.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row6,'String','Frequency Band (Hz):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            uicontrol( 'Style','edit','Parent', mep_panel_row6 ,'FontSize',11);
            uicontrol( 'Style','edit','Parent', mep_panel_row6 ,'FontSize',11);
            set(mep_panel_row6,'Widths',[150 -2 -2]);
            
            uiextras.HBox( 'Parent', obj.pi.rtms.vb)
            
            
            obj.pi.mep.run=uicontrol( 'Parent', obj.pi.rtms.vb ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            
            
            set(obj.pi.rtms.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -3 -0.4 ])
            
        end
        
        
        function pr_eegtms(obj)
            obj.pr.mt.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.pr.mt.hbox=uix.HBoxFlex( 'Parent', obj.pr.mt.handle, 'Padding', 5 ,'Units','normalized' );
            obj.pr.mt.panel_mep= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live Phase Histogram','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mt.panel_mtplot= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Treatment Time Series Avg','FontSize',12,'TitlePosition','centertop' );
            
            m_mep=uicontextmenu(obj.fig.handle);
            uimenu(m_mep,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_mt_export_mepplot);
            
            m_mt=uicontextmenu(obj.fig.handle);
            uimenu(m_mt,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_mt_export_mtplot);
            
            %             obj.pr.eegtms.axes1=axes( 'Parent',  obj.pr.mt.panel_mep,'Units','normalized','Tag','mep','uicontextmenu',m_mep);
            obj.pr.eegtms.axes1=polaraxes( 'Parent',  obj.pr.mt.panel_mep,'Units','normalized','Tag','mep','uicontextmenu',m_mep);
            
            obj.pr.eegtms.axes2=axes( 'Parent',obj.pr.mt.panel_mtplot,'Units','normalized','Tag','rmt','uicontextmenu',m_mt);
            set(obj.pr.mt.hbox,'Widths',[-1 -1])
        end
        function tmsfmri_stop(obj)
            clear obj.info.a;
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
            
            
            a=[];
            
            % %             a=arduino;
            
            
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
            save([file_name '_trial_vector.mat'], 'trial_vector');
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
                delete(instrfindall);
                magventureObject = magventure('COM7'); %0808a
                magventureObject.connect;
                magventureObject.arm
                
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
                                    magventureObject.setAmplitude(intensity_vector(i));
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
                    if(N==total_volumes)
                        break
                    end
                end
                
                set(obj.pi.tmsfmri.status,'String','Completed!');
            end % (manual stim intensity if flag end)
        end
        function cb_pi_tmsfmri_manual_stim_inten(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).manual_stim_inten=(obj.pi.tmsfmri.manual_stim_inten.Value);
        end
        %% results panel
        function create_results_panel(obj)
            obj.pr.empty_panel= uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            %             set( obj.fig.main, 'Widths', [-1.15 -1.35 -2] );
        end
        
        function pr_hotspot(obj)
            obj.pr.hotspot.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            m_mep=uicontextmenu(obj.fig.handle);
            uimenu(m_mep,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_hotspot_export_mepplot);
            obj.pr.hotspot.axes1=axes( 'Parent', obj.pr.hotspot.handle,'Units','normalized','Tag','mep','uicontextmenu',m_mep);
        end
        function pr_mt(obj)
            
            
            obj.pr.mt.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.pr.mt.hbox=uix.HBoxFlex( 'Parent', obj.pr.mt.handle, 'Padding', 5 ,'Units','normalized' );
            obj.pr.mt.panel_mep= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mt.panel_mtplot= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live Intensity Trace','FontSize',12,'TitlePosition','centertop' );
            
            m_mep=uicontextmenu(obj.fig.handle);
            uimenu(m_mep,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_mt_export_mepplot);
            
            m_mt=uicontextmenu(obj.fig.handle);
            uimenu(m_mt,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_mt_export_mtplot);
            
            obj.pr.mt.axes_mep=axes( 'Parent',  obj.pr.mt.panel_mep,'Units','normalized','Tag','mep','uicontextmenu',m_mep);
            obj.pr.mt.axes_mtplot=axes( 'Parent',obj.pr.mt.panel_mtplot,'Units','normalized','Tag','rmt','uicontextmenu',m_mt);
            set(obj.pr.mt.hbox,'Widths',[-1 -1])
            
            
        end
        function pr_ioc(obj)
            
            
            obj.pr.ioc.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            tab = uiextras.TabPanel( 'Parent', obj.pr.ioc.handle, 'Padding', 5 );
            
            
            obj.pr.ioc.hbox=uix.HBoxFlex( 'Parent', tab, 'Padding', 5 ,'Units','normalized' );
            obj.pr.ioc.panel_mep= uix.Panel( 'Parent', obj.pr.ioc.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ioc.panel_scatplot= uix.Panel( 'Parent', obj.pr.ioc.hbox, 'Padding', 5 ,'Units','normalized','Title', 'MEP P2P Scatt Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ioc.panel_fitplot= uix.Panel( 'Parent', tab, 'Padding', 5 ,'Units','normalized','Title', 'Fitted Dose-Response Curve','FontSize',12,'TitlePosition','centertop' );
            
            m_mep=uicontextmenu(obj.fig.handle);
            uimenu(m_mep,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_ioc_export_mepplot);
            
            m_scatplot=uicontextmenu(obj.fig.handle);
            uimenu(m_scatplot,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_ioc_export_scatplot);
            
            m_iocfit=uicontextmenu(obj.fig.handle);
            uimenu(m_iocfit,'label','Export as Matlab Figure','Callback',@(~,~)obj.cb_pr_ioc_export_iocfit);
            
            
            
            
            
            obj.pr.ioc.axes_mep=axes( 'Parent',  obj.pr.ioc.panel_mep,'Units','normalized','Tag','mep','uicontextmenu',m_mep);
            obj.pr.ioc.axes_scatplot=axes( 'Parent',obj.pr.ioc.panel_scatplot,'Units','normalized','Tag','ioc','uicontextmenu',m_scatplot);
            obj.pr.ioc.axes_fitplot=axes( 'Parent',obj.pr.ioc.panel_fitplot,'Units','normalized','Tag','ioc_fit','uicontextmenu',m_iocfit);
            
            set(obj.pr.ioc.hbox,'Widths',[-1 -1])
            
            tab.TabNames={'Live Results','Fitted IOC'};
            tab.SelectedChild=1;
            tab.TabSize=200;
            tab.FontSize=12;
            
        end
        %%  hardware configuration panel
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
            if (obj.hw.vbox_rp.slct_device2.Value<=4)
                obj.hw_output_pc
            elseif(obj.hw.vbox_rp.slct_device2.Value>4)
                obj.hw_output_neurone
            end
        end
        function cb_cfg_newdevice(obj)
            obj.hw_input_neurone
            obj.hw.device_added1.listbox.Value=1
            obj.hw.device_added2.listbox.Value=1
        end
        function hw_input_neurone(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Devie Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Box controlled NeurOne','FieldTrip Real-Time Buffer'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',1);
            set(row1,'Widths',[200 -2]);
            
            
            row2=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row2,'String','Device Reference Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.device_name=uicontrol( 'Style','edit','Parent', row2 ,'FontSize',11);
            set(row2,'Widths',[200 -2]);
            
            
            row3=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row3,'String','Protocol File Name','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.prtcl_name=uicontrol( 'Style','edit','Parent', row3 ,'FontSize',11,'String','neurone.xml');
            set(row3,'Widths',[200 -2]);
            
            uiextras.HBox( 'Parent', obj.hw.vbox_rightpanel)
            
            uicontrol( 'Parent', obj.hw.vbox_rightpanel ,'Style','PushButton','String','Add Device','FontWeight','Bold','Callback',@(~,~)obj.cb_add_input)
            
            
            
            
            set(obj.hw.vbox_rightpanel,'Heights',[-1 -1 -1 -1 -9 -1])
            
        end
        function hw_input_ft(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Devie Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',1);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'BOSS Box controlled NeurOne','FieldTrip Real-Time Buffer'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device,'Value',2);
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
        function hw_output_neurone(obj)
            delete(obj.hw.vbox_rightpanel)
            
            obj.hw.vbox_rightpanel=uix.VBox( 'Parent', obj.hw.rightpanel, 'Spacing', 5, 'Padding', 5  );
            
            row0=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row0,'String','Devie Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',2);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device2=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Host PC controlled MagVenture','Host PC controlled MagStim','Host PC controlled BiStim','Host PC controlled Rapid','BOSS Box controlled MagVenture','BOSS Box controlled MagStim','BOSS Box controlled BiStim','BOSS Box controlled Rapid','Simulation'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device2,'Value',obj.hw.output.slct_device2);
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
            uicontrol( 'Style','text','Parent', row0,'String','Devie Type','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.device_type.listbox=uicontrol( 'Style','popupmenu','Parent', row0 ,'FontSize',11,'String',{'Input Device (Recording Device)','Output Device (Stimulating Device)'},'Callback',@(~,~)obj.cb_hw_device_type_listbox,'Value',2);
            set(row0,'Widths',[200 -2]);
            
            row1=uix.HBox( 'Parent', obj.hw.vbox_rightpanel, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', row1,'String','Select Device','FontSize',12,'HorizontalAlignment','left','Units','normalized');
            obj.hw.vbox_rp.slct_device2=uicontrol( 'Style','popupmenu','Parent', row1 ,'FontSize',11,'String',{'Host PC controlled MagVenture','Host PC controlled MagStim','Host PC controlled BiStim','Host PC controlled Rapid','BOSS Box controlled MagVenture','BOSS Box controlled MagStim','BOSS Box controlled BiStim','BOSS Box controlled Rapid','Simulation'},'Callback',@(~,~)obj.cb_hw_vbox_rp_slct_device2,'Value',obj.hw.output.slct_device2);
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
        function cb_add_output(obj)
            
            obj.hw.device_added2_listbox.string(numel(obj.hw.device_added2_listbox.string)+1)=cellstr(obj.hw.vbox_rp.device_name.String);
            obj.hw.device_added2.listbox.String=obj.hw.device_added2_listbox.string;
            if(obj.hw.device_type.listbox.Value==2)
                switch obj.hw.vbox_rp.slct_device2.Value
                    case {1,2,3,4}
                        obj.cb_hw_output_pc_parsaving;
                    case {5,6,7,8,9}
                        obj.cb_hw_output_neurone_parsaving;
                end
            end
        end
        function cb_add_input(obj)
            
            obj.hw.device_added1_listbox.string(numel(obj.hw.device_added1_listbox.string)+1)=cellstr(obj.hw.vbox_rp.device_name.String);
            obj.hw.device_added1.listbox.String=obj.hw.device_added1_listbox.string;
            if(obj.hw.device_type.listbox.Value==1)
                switch obj.hw.vbox_rp.slct_device.Value
                    case 1
                        obj.cb_hw_input_neurone_parsaving;
                    case 2
                        obj.cb_hw_input_ft_parsaving;
                end
            end
            
            
        end
        function cb_hw_vbox_rp_slct_device (obj)
            switch obj.hw.vbox_rp.slct_device.Value
                case 1
                    obj.hw_input_neurone
                case 2
                    obj.hw_input_ft
            end
            
        end
        
        function cb_hw_input_neurone_parsaving(obj)
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_type=obj.hw.device_type.listbox.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).slct_device=obj.hw.vbox_rp.slct_device.Value;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).device_name=obj.hw.vbox_rp.device_name.String;
            obj.par.hardware_settings.(obj.hw.vbox_rp.device_name.String).prtcl_name=obj.hw.vbox_rp.prtcl_name.String;
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
        
        function cb_hw_listbox_input(obj)
            slctd_input=char(obj.hw.device_added1.listbox.String(obj.hw.device_added1.listbox.Value));
            
            switch obj.par.hardware_settings.(slctd_input).slct_device
                case 1
                    %                     obj.cb_hw_input_neurone_parsaving;
                    obj.hw_input_neurone;
                    obj.hw.device_type.listbox.Value=obj.par.hardware_settings.(slctd_input).device_type;
                    obj.hw.vbox_rp.slct_device.Value=obj.par.hardware_settings.(slctd_input).slct_device;
                    
                    obj.hw.vbox_rp.device_name.String=obj.par.hardware_settings.(slctd_input).device_name;
                    obj.hw.vbox_rp.prtcl_name.String=obj.par.hardware_settings.(slctd_input).prtcl_name;
                    
                case 2
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
            obj.info.session_no
            obj.info.session_no=obj.info.session_no+1;
            
            session_name_registering=obj.pmd.sess_title.editfield.String
            session_name_registering(session_name_registering == ' ') = '_'
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
            
            
            session_name=session_name_registering
            
            if ~any(strcmp(obj.info.session_matrix,session_name))
                obj.info.session_matrix(obj.info.session_no)={session_name};
                obj.pmd.lb_sessions.string(obj.info.session_no)={session_name};
                obj.pmd.lb_sessions.listbox.String=obj.pmd.lb_sessions.string;
                
                
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
            obj.info.event.measure_being_added_original=obj.info.event.measure_being_added_original{1}
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
            %   obj.data.(obj.info.event.current_session).(measure_name).mep.target_muscle={};
            
            
            obj.info.event.measure_being_added=measure_name
            obj.func_create_defaults
            obj.cb_session_listbox
            obj.cb_measure_listbox
            
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
            
            
        end
        function cb_measure_listbox(obj)
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
            switch obj.info.event.current_measure
                case 'MEP Measurement'
                    obj.pi_mep;
                    obj.func_load_mep_par;
                case 'MEP Hotspot Search'
                    obj.pi_hotspot;
                    obj.func_load_hotspot_par;
                case 'MEP Motor Threshold Hunting'
                    obj.pi_mt_ptc;
                    obj.func_load_mt_ptc_par;
                case 'TMS fMRI'
                    obj.pi_tmsfmri;
                    obj.func_load_tmsfmri_par;
                case 'MEP Dose Response Curve_sp'
                    obj.pi_ioc;
                    obj.func_load_ioc_par;
                    
                case 'EEG triggered Stimulation'
                    obj.pi_eegtms
                    obj.pr_eegtms
                    obj.func_load_eegtms_par;
                case 'TEP Measurement'
                    obj.pi_tep
                    %                     obj.func_load_mep_par;
                case 'ERP Measurement'
                    obj.pi_erp
                    %                     obj.func_load_mep_par;
                case 'rs EEG Analysis'
                    obj.pi_rseeg;
                case 'rTMS Interventions'
                    obj.pi_rtms_train
                case 'Multimodal Experiment'
%                     obj.pi_multimodal;
%                     obj.func_load_multimodal_par;
                case 'MEP IOC_new'
                    obj.pi_multimodal_ioc;
                    obj.func_load_multimodal_par;
            end
            % obj.info.event.current_measure(obj.info.event.current_measure == ' ') = '_';
            
            
            %  obj.func_load_par
            
            %                         current_measure=obj.info.event.current_measure;
            %           obj.inputs.mep.target_muscle.String=obj.data.(obj.info.event.current_session).(current_measure).mep.target_muscle
            
            
        end
        %% load defaults and pars
        function func_create_defaults(obj)
            disp('defaults entered ------------------------------------------------------------------------')
            switch obj.info.event.measure_being_added_original
                case 'MEP Measurement'
                    obj.default_par_mep;
                case 'MEP Hotspot Search'
                    obj.default_par_hotspot;
                case 'MEP Motor Threshold Hunting'
                    obj.default_par_mt_ptc;
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
            end
        end
        
        
        
        
        function default_par_tmsfmri(obj)
            obj.info.defaults.target_muscle='APBr';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            obj.info.defaults.trials_per_condition=[15];
            obj.info.defaults.iti=[4 6];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=20;
            obj.info.defaults.poststim_scope_plt=100;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+5000;
            obj.info.defaults.ylim_min=-5000;
            obj.info.defaults.FontSize=14;
            obj.info.defaults.mt_mv=0.05;
            obj.info.defaults.thresholding_method=2;
            obj.info.defaults.trials_to_avg=15;
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
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
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
        %% run n update
        
        
        
        
        function cb_pi_eegtms_run(obj)
            
            target_montage_channels={'C3', 'FC1', 'FC5', 'CP1', 'CP5'};
            target_montage_weights=[1 -0.25 -0.25 -0.25 -0.25];
            neurone_protocol='RMT - Duplicate_NeurOneProtocol.xml';
            
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.phase_angle=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_phase;
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            obj.bst.inputs.trials=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.bst.inputs.iti=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti;
            obj.bst.inputs.phase_tolerance=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).phase_tolerance;
            obj.bst.inputs.amp_low=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_low;
            obj.bst.inputs.amp_hi=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_hi;
            obj.bst.inputs.offset_samples=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).offset_samples;
            
            
            
            
            
            obj.bst.inputs.target_montage_channels=target_montage_channels;
            obj.bst.inputs.target_montage_weights=target_montage_weights;
            obj.bst.inputs.neurone_protocol=neurone_protocol;
            obj.bst.best_eegtms;
            
            %             phase_angle=[pi 0];
            %             stim_intensity=50;
            %             trials_per_condition=200;
            %             iti=[1];
            %             phase_tolerance=pi/50;
            %             %attach neurone protocole file in the settings panel
            %             % things to be taken from the hardware configuration
            %             target_montage_channels={'C3', 'FC1', 'FC5', 'CP1', 'CP5'};
            %             target_montage_weights=[1 -0.25 -0.25 -0.25 -0.25];
            %             neurone_protocol='RMT - Duplicate_NeurOneProtocol.xml'
            %
            %             obj.bst.inputs.current_session=obj.info.event.current_session;
            %             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %             obj.bst.inputs.phase_angle=phase_angle
            %             obj.bst.inputs.stimuli=stim_intensity
            %             obj.bst.inputs.trials=trials_per_condition
            %             obj.bst.inputs.iti=iti
            %             obj.bst.inputs.phase_tolerance=phase_tolerance
            %             obj.bst.inputs.target_montage_channels=target_montage_channels
            %             obj.bst.inputs.target_montage_weights=target_montage_weights
            %             obj.bst.inputs.neurone_protocol=neurone_protocol
            %
            %             obj.bst.best_eegtms
            
            
            
            
            
        end
        %% input callbacks
        
        %% hotspot inputs callbacks
        
        %% motor thresholding inputs callbacks
        function cb_pi_mt_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.mt.target_muscle.String;
        end
        function cb_pi_mt_thresholding_method(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_method=str2num(obj.pi.mt.thresholding_method.Value);
        end
        function cb_pi_mt_mt_mv(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv=str2num(obj.pi.mt.mt_mv.String);
        end
        function cb_pi_mt_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=str2num(obj.pi.mt.trials_per_condition.String);
        end
        function cb_pi_mt_trials_to_avg(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg=str2num(obj.pi.mt.trials_to_avg.String);
        end
        function cb_pi_mt_iti(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.mt.iti.String);
        end
        function cb_pi_mt_mep_onset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset=str2num(obj.pi.mt.mep_onset.String);
        end
        function cb_pi_mt_mep_offset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset=str2num(obj.pi.mt.mep_offset.String);
        end
        function cb_pi_mt_prestim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext=str2num(obj.pi.mt.prestim_scope_ext.String);
        end
        function cb_pi_mt_poststim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext=str2num(obj.pi.mt.poststim_scope_ext.String);
        end
        function cb_pi_mt_prestim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt=str2num(obj.pi.mt.prestim_scope_plt.String);
        end
        function cb_pi_mt_poststim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt=str2num(obj.pi.mt.poststim_scope_plt.String);
        end
        function cb_pi_mt_ylim_min(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min=str2num(obj.pi.mt.ylim_min.String);
        end
        function cb_pi_mt_ylim_max(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max=str2num(obj.pi.mt.ylim_max.String);
        end
        function cb_pi_mt_FontSize(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize=str2num(obj.pi.mt.FontSize.String);
        end
        function cb_pi_mt_trials_for_mean_annotation(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation=str2num(obj.pi.mt.trials_for_mean_annotation.String);
        end
        function cb_pi_mt_trials_reset(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed_counter=0;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed=1;
        end
        function cb_pi_mt_plot_reset(obj)
            delete(obj.bst.info.handles.mean_mep_plot)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
        end
        function cb_pi_mt_save_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt=obj.pi.mt.save_plt.Value;
        end
        function cb_pi_mt_result_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).result_mt=str2double(obj.pi.mt.result_mt.String);
        end
        %% ioc calbacks
        
        %% tms fmri callbacks
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
        function cb_menu_save(obj)
            try
                exp_name=obj.pmd.exp_title.editfield.String;
                exp_name(exp_name == ' ') = '_';
                
                subj_code=obj.pmd.sub_code.editfield.String;
                subj_code(subj_code == ' ') = '_';
                save_str=[exp_name '_' subj_code];
                obj.bst.info.save_str=save_str;
                obj.bst.info.save_str_runtime=[save_str '_runtime_backup'];
                variable_saved.(save_str).par=obj.par
                variable_saved.(save_str).par.global_info=obj.info
                variable_saved.(save_str).par.global_data=obj.data
                variable_saved.(save_str).par.exp_name=exp_name;
                variable_saved.(save_str).par.subj_code=subj_code;
                variable_saved.(save_str).par.sess=obj.pmd.lb_sessions.string;
                
                variable_saved.(save_str).data.sessions=obj.bst.sessions
                variable_saved.(save_str).data.global_info.inputs=obj.bst.inputs
                variable_saved.(save_str).data.global_info.info=obj.bst.info
                variable_saved.(save_str).data.global_info.info.axes=[];
                % %             varsav=variable_saved.(save_str)
                % %             save(save_str,'varsav')
                
                matfilstr=[save_str '_matfile.mat']
                obj.bst.info.save_buffer = matfile(matfilstr,'Writable',true)
                obj.bst.info.save_buffer.(save_str)=variable_saved.(save_str)
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
                % %             varr.sess=obj.pmd.lb_sessions.string;
                
                
                
                
                
                %             save('C:\0. HARD DISK\BEST Toolbox\BEST-04.08\GUI\save',save_str,'obj')
                %             save(save_str,'varr')
            catch
                disp prob is here
            end
            
        end
        function cb_menu_load(obj)
            file = uigetfile;
            varname=file;
            varname=erase(varname,'_matfile.mat');
            saved_struct=load(file,varname);
            obj.par=saved_struct.(varname).par;
            obj.info=saved_struct.(varname).par.global_info;
            obj.data=saved_struct.(varname).par.global_data;
            obj.bst.sessions=saved_struct.(varname).data.sessions;
            obj.bst.inputs=saved_struct.(varname).data.global_info.inputs;
            obj.bst.info=saved_struct.(varname).data.global_info.info;
            obj.pmd.exp_title.editfield.String=saved_struct.(varname).par.exp_name;
            obj.pmd.sub_code.editfield.String=saved_struct.(varname).par.subj_code;
            obj.pmd.lb_sessions.listbox.String=saved_struct.(varname).par.sess;
            obj.cb_session_listbox;
        end
        function cb_menu_md(obj)
            obj.info.menu.md=obj.info.menu.md+1;
            if bitget(obj.info.menu.md,1) %odd
                obj.fig.main.Widths(1)=0;
                
                
                
            else %even
                obj.fig.main.Widths(1)=-1.15;
                
            end
        end
        function cb_menu_ip(obj)
            obj.info.menu.ip=obj.info.menu.ip+1;
            if bitget(obj.info.menu.ip,1) %odd
                obj.fig.main.Widths(2)=0;
            else %even
                obj.fig.main.Widths(2)=-1.35;
            end
        end
        function cb_menu_rp(obj)
            obj.info.menu.rp=obj.info.menu.rp+1;
            if bitget(obj.info.menu.rp,1) %odd
                obj.fig.main.Widths(3)=0;
            else %even
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
            else %even
                obj.fig.main.Widths(1)=-1.15;
                obj.fig.main.Widths(2)=-1.35;
                obj.fig.main.Widths(3)=-2;
                obj.fig.main.Widths(4)=0;
            end
        end
        
        function best_stop(obj)
            uiresume
            obj.bst.inputs.stop_event=1;
            
        end
        %% PEST Taylor
        function pi_mt_ptc(obj)
            obj.pi.mt_ptc.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Threshold Hunting' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mt_ptc.vb = uix.VBox( 'Parent', obj.pi.mt_ptc.panel, 'Spacing', 5, 'Padding', 5  );
            
            %             % row 1
            %             uiextras.HBox( 'Parent', obj.pi.mt_ptc.vb,'Spacing', 5, 'Padding', 2 )
            %             mep_panel_row1 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Thresholding Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.thresholding_method=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'PEST Pentland', 'PEST Taylor'},'Value',2,'Callback',@(~,~)obj.cb_pi_mt_ptc_thresholding_method);
            %             set( mep_panel_row1, 'Widths', [150 -2]);
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Input Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.input_device=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_input_device); %,'Callback',@obj.cb_mt_ptc_target_muscle
            str_in_device(1)= (cellstr('Select'));
            str_in_device(2:numel(obj.hw.device_added1_listbox.string)+1)=obj.hw.device_added1_listbox.string;
            
            obj.pi.mt_ptc.input_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2 ,'FontSize',11,'String',str_in_device,'Callback',@(~,~)obj.cb_pi_mt_ptc_input_device); %,'Callback',@obj.cb_mt_ptc_target_muscle
            
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 2f
            mep_panel_row2f = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2f,'String','Output Device:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.output_device=uicontrol( 'Style','edit','Parent', mep_panel_row2f ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_output_device); %,'Callback',@obj.cb_mt_ptc_target_muscle
            str_out_device(1)= (cellstr('Select'));
            str_out_device(2:numel(obj.hw.device_added2_listbox.string)+1)=obj.hw.device_added2_listbox.string;
            obj.pi.mt_ptc.output_device=uicontrol( 'Style','popupmenu','Parent', mep_panel_row2f ,'String',str_out_device,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_output_device); %,'Callback',@obj.cb_mt_ptc_target_muscle
            
            set( mep_panel_row2f, 'Widths', [150 -2]);
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_target_muscle); %,'Callback',@obj.cb_mt_ptc_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            
            % row 2g
            mep_panel_row2g = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2g,'String','Display Channels:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.display_scopes=uicontrol( 'Style','edit','Parent', mep_panel_row2g ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_display_scopes); %,'Callback',@obj.cb_mt_ptc_target_muscle
            set( mep_panel_row2g, 'Widths', [150 -2]);
            
            
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Motor Threshold (mV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.mt_mv=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_mt_mv);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Starting Stim. Intensity (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.mt_starting_stim_inten=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_starting_stim_inten);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            % row 4A
            mep_panel_row4A = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row4A,'String','No of Trials:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4A ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_trials_per_condition);
            set( mep_panel_row4A, 'Widths', [150 -2]);
            
            % row c
            mep_panel_rowC = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_rowC,'String','No. of Trials to Avg:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.trials_to_avg=uicontrol( 'Style','edit','Parent', mep_panel_rowC ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_trials_to_avg);
            set( mep_panel_rowC, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            %             % row 6
            %             uiextras.HBox( 'Parent', obj.pi.mt_ptc.vb)
            %
            % row 7
            %             uicontrol( 'Style','text','Parent',  obj.pi.mt_ptc.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_mt_ptc_mep_onset);
            obj.pi.mt_ptc.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_ptc_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %             %row 9
            %             mep_panel_row10 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_ptc_prestim_scope_ext);
            %             obj.pi.mt_ptc.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mt_ptc_poststim_scope_ext);
            %             set( mep_panel_row10, 'Widths', [150 -2 -2]);
            %
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mt_ptc_prestim_scope_plt);
            obj.pi.mt_ptc.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_mt_ptc_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            
            
            %             % row 15
            %             mep_panel_15 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mt_ptc_ylim_min);
            %             obj.pi.mt_ptc.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mt_ptc_ylim_max);
            %             set( mep_panel_15, 'Widths', [150 -2 -2]);
            %
            %
            %             % row 14
            %             mep_panel_14 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_mt_ptc_FontSize);
            %             set( mep_panel_14, 'Widths', [150 -2]);
            %
            %
            %
            %             % row 16
            %             mep_panel_16 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_16,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_mt_ptc_trials_for_mean_annotation);
            %             obj.pi.mt_ptc.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_mt_ptc_trials_reset);
            %             obj.pi.mt_ptc.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Mean Plot','Callback',@(~,~)obj.cb_pi_mt_ptc_plot_reset);
            %
            %             set( mep_panel_16, 'Widths', [150 -1 -2 -2]);
            %
            %             % row 18a
            %             mep_panel_18a = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            %             uicontrol( 'Style','text','Parent', mep_panel_18a,'String','Save Plot:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            %             obj.pi.mt_ptc.save_plt=uicontrol( 'Style','checkbox','Parent', mep_panel_18a ,'FontSize',11,'Value',obj.info.defaults.save_plt,'Callback',@(~,~)obj.cb_pi_mt_ptc_save_plt);
            %             set( mep_panel_18a, 'Widths', [-2 -2]);
            
            % row 19
            mep_panel_19 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            uicontrol( 'Style','text','Parent', mep_panel_19,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt_ptc.result_mt=uicontrol( 'Style','edit','Enable','off','Parent', mep_panel_19 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_ptc_result_mt);
            set( mep_panel_19, 'Widths', [-2 -2]);
            
            
            uiextras.HBox( 'Parent', obj.pi.mt_ptc.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mt_ptc.vb, 'Spacing', 5, 'Padding', 2  );
            obj.pi.mt_ptc.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_ptc_update);
            obj.pi.mt_ptc.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_ptc_run);
            obj.pi.pause=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Pause','FontWeight','Bold','Callback',@(~,~)obj.pause,'Enable','on');
            
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2 -2]);
            
            set(obj.pi.mt_ptc.vb,'Heights',[-0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -2 -0.5])
        end
        function default_par_mt_ptc(obj)
            obj.info.defaults.input_device=1;
            obj.info.defaults.output_device=1;
            obj.info.defaults.display_scopes='';
            obj.info.defaults.target_muscle='';
            obj.info.defaults.stimulation_intensities=NaN;
            obj.info.defaults.trials_per_condition=[50];
            obj.info.defaults.iti=[4 6];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=50;
            obj.info.defaults.poststim_scope_plt=150;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt=[];
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+200;
            obj.info.defaults.ylim_min=-200;
            obj.info.defaults.FontSize=14;
            obj.info.defaults.mt_mv=0.05;
            obj.info.defaults.thresholding_method=2;
            obj.info.defaults.trials_to_avg=15;
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
            obj.info.defaults.result_mt=[];
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
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults;
        end
        function func_load_mt_ptc_par(obj)
            obj.pi.mt_ptc.input_device.Value=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device;
            obj.pi.mt_ptc.output_device.Value= obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device;
            obj.pi.mt_ptc.display_scopes.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes;
            obj.pi.mt_ptc.target_muscle.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle;
            obj.pi.mt_ptc.mt_mv.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv);
            obj.pi.mt_ptc.trials_per_condition.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.pi.mt_ptc.mt_starting_stim_inten.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_inten;
            obj.pi.mt_ptc.trials_to_avg.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg);
            obj.pi.mt_ptc.iti.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.mt_ptc.mep_onset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset;
            obj.pi.mt_ptc.mep_offset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset;
            %             obj.pi.mt_ptc.prestim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext);
            %             obj.pi.mt_ptc.poststim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext);
            obj.pi.mt_ptc.prestim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt);
            obj.pi.mt_ptc.poststim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt);
            %             obj.pi.mt_ptc.ylim_max.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            %             obj.pi.mt_ptc.ylim_min.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            %             obj.pi.mt_ptc.FontSize.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            %             obj.pi.mt_ptc.trials_for_mean_annotation.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation);
            obj.pi.mt_ptc.result_mt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).result_mt);
            
            
            obj.pi.mt_ptc.run.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable;
            obj.pi.mt_ptc.target_muscle.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable;
            obj.pi.mt_ptc.mt_mv.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mvEnable;
            %             obj.pi.mt_ptc.prestim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable;
            %             obj.pi.mt_ptc.poststim_scope_ext.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable;
            %             obj.pi.mt_ptc.thresholding_method.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_methodEnable;
            obj.pi.mt_ptc.trials_per_condition.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable;
            obj.pi.mt_ptc.mt_starting_stim_inten.Enable=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_intenEnable;
            
        end
        function cb_pi_mt_ptc_run(obj)
            obj.bst.inputs.measure_str=cellstr('Motor Threshold Hunting');
            obj.bst.inputs.input_device=obj.pi.mt_ptc.input_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device));
            obj.bst.inputs.output_device=obj.pi.mt_ptc.output_device.String((obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device));
            obj.bst.inputs.target_muscle=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.bst.inputs.display_scopes=eval(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes);
            obj.bst.inputs.stimuli=num2cell(NaN);
            if(numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)==1 || numel(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)>2)
                obj.bst.inputs.iti=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            else
                obj.bst.inputs.iti={num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti)};
            end
            
            obj.bst.inputs.trials=num2cell(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            obj.bst.inputs.ylimMax=200;
            obj.bst.inputs.ylimMin=-200;
            
            
            obj.bst.inputs.motor_threshold=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv;
            obj.bst.inputs.mt_trialstoavg=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg;
            
            obj.bst.inputs.mt_starting_stim_inten=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_inten);
            
            obj.bst.inputs.stim_mode='MSO';
            obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            
            obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            
            obj.bst.factorizeConditions;
            obj.bst.planTrials
            obj.resultsPanel;
            obj.bst.boot_inputdevice;
            obj.bst.boot_outputdevice;
            obj.bst.boot_threshold;
            obj.bst.bootTrial;
            obj.bst.stimLoop
            % % % % for tt=1:obj.bst.inputs.totalTrials
            % % % %     obj.bst.trigTrial;
            % % % %     obj.bst.readTrial;
            % % % %     obj.bst.prepTrial;
            % % % %     obj.bst.plotTrial;
            % % % %
            % % % %     %             pause(obj.bst.inputs.trialMat{obj.bst.inputs.trial,obj.bst.inputs.colLabel.iti}-toc)
            % % % %     wait_period=obj.bst.inputs.trialMat{obj.bst.inputs.trial,obj.bst.inputs.colLabel.iti}-toc;
            % % % %     wait_idx=3*floor(wait_period);
            % % % %     for wait_id=1:wait_idx
            % % % %         pause(wait_period/wait_idx)
            % % % %         if(obj.bst.inputs.stop_event==1)
            % % % %             break;
            % % % %         end
            % % % %     end
            % % % %     if(obj.bst.inputs.stop_event==1)
            % % % %         disp('returned after the execution')
            % % % %         obj.bst.inputs.stop_event=0;
            % % % %         break;
            % % % %     end
            % % % % end
            
            
            %             OLD SCRIPT
            %             obj.disable_listboxes
            %             delete(obj.pr.mep.axes1)
            %             delete(obj.pr.hotspot.axes1)
            %             delete(obj.pr.mt.axes_mep)
            %             delete(obj.pr.mt.axes_mtplot)
            %             delete(obj.pr.ioc.axes_mep)
            %             delete(obj.pr.ioc.axes_scatplot)
            %             delete(obj.pr.ioc.axes_fitplot)
            %
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            %             obj.pi.mt_ptc.thresholding_method.Enable='off';
            %             obj.pi.mt_ptc.mt_mv.Enable='off';
            %             obj.pi.mt_ptc.run.Enable='off';
            %             obj.pi.mt_ptc.target_muscle.Enable='off';
            %             obj.pi.mt_ptc.trials_per_condition.Enable='off';
            %             obj.pi.mt_ptc.mt_starting_stim_inten.Enable='off';
            %             obj.pi.mt_ptc.prestim_scope_ext.Enable='off';
            %             obj.pi.mt_ptc.poststim_scope_ext.Enable='off';
            %
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).runEnable=obj.pi.mt_ptc.run.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscleEnable=obj.pi.mt_ptc.target_muscle.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mvEnable=obj.pi.mt_ptc.mt_mv.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_extEnable=obj.pi.mt_ptc.prestim_scope_ext.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_extEnable=obj.pi.mt_ptc.poststim_scope_ext.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_methodEnable=obj.pi.mt_ptc.thresholding_method.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_conditionEnable=obj.pi.mt_ptc.trials_per_condition.Enable;
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_intenEnable=obj.pi.mt_ptc.mt_starting_stim_inten.Enable;
            %
            %             obj.bst.inputs.current_session=obj.info.event.current_session;
            %             obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            %             obj.bst.inputs.motor_threshold=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv;
            %             obj.bst.inputs.mt_trialstoavg=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg;
            %             obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            %             obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            %             obj.bst.inputs.mt_starting_stim_inten=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_inten);
            %
            %             obj.bst.inputs.stim_mode='MSO';
            %             obj.bst.inputs.mep_onset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset)/1000;
            %             obj.bst.inputs.mep_offset=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset)/1000;
            %             obj.bst.inputs.prestim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext;
            %             obj.bst.inputs.poststim_scope_ext=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext;
            %             obj.bst.inputs.prestim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt;
            %             obj.bst.inputs.poststim_scope_plt=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt;
            %             obj.bst.inputs.FontSize=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            %             obj.bst.inputs.ylim_min=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            %             obj.bst.inputs.ylim_max=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            %             obj.bst.inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            %             obj.bst.inputs.reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).reset_pressed;
            %             obj.bst.inputs.plot_reset_pressed=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).plot_reset_pressed;
            %             obj.pr_mt;
            %             obj.cb_menu_save;
            %
            %
            %             obj.bst.best_motorthreshold_pest_tc;
            %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).results.mt
            %
            %             obj.pi.mt_ptc.result_mt.String=num2str(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).results.mt);
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stop_event=1;
            %             obj.cb_pi_mt_ptc_result_mt
            %
            %             if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt==1)
            %                 exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            %                 sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            %                 sess=obj.info.event.current_session;
            %                 meas=obj.info.event.current_measure_fullstr;
            %                 plt='MEP_Plot';
            %                 timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.mt.axes_mep,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %
            %                 plt='MotorThreshold_Plot';
            %                 file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            %                 figg=figure('Visible','off','CreateFcn','set(gcf,''Visible'',''on'')','Name',file_name,'NumberTitle','off');
            %                 copyobj(obj.pr.mt.axes_mtplot,figg)
            %                 set( gca, 'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.7] );
            %                 saveas(figg,file_name,'fig');
            %                 close(figg)
            %             end
            %             obj.enable_listboxes
            %             obj.cb_menu_save;
            %             delete(sprintf('%s.mat',obj.bst.info.save_str_runtime));
            %
        end
        function cb_pi_mt_ptc_update(obj)
            session=obj.info.event.current_session
            measure=obj.info.event.current_measure_fullstr
            % updating MT by updating no of trials to avg property
            
            obj.bst.sessions.(session).(measure).info.update_event=1;
            
            obj.bst.inputs.mt_trialstoavg=obj.par.(session).(measure).trials_to_avg;
            obj.bst.inputs.iti=(obj.par.(session).(measure).iti);
            obj.bst.inputs.mep_onset=(obj.par.(session).(measure).mep_onset)/1000;
            obj.bst.inputs.mep_offset=(obj.par.(session).(measure).mep_offset)/1000;
            obj.bst.inputs.prestim_scope_ext=obj.par.(session).(measure).prestim_scope_ext;
            obj.bst.inputs.poststim_scope_ext=obj.par.(session).(measure).poststim_scope_ext;
            obj.bst.inputs.prestim_scope_plt=obj.par.(session).(measure).prestim_scope_plt;
            obj.bst.inputs.poststim_scope_plt=obj.par.(session).(measure).poststim_scope_plt;
            obj.bst.inputs.FontSize=(obj.par.(session).(measure).FontSize);
            obj.bst.inputs.ylim_min=(obj.par.(session).(measure).ylim_min);
            obj.bst.inputs.ylim_max=(obj.par.(session).(measure).ylim_max);
            obj.bst.inputs.trials_for_mean_annotation=obj.par.(session).(measure).trials_for_mean_annotation;
            
            obj.bst.inputs.plot_reset_pressed=obj.par.(session).(measure).plot_reset_pressed;
            obj.bst.sessions.(session).(measure).inputs=obj.bst.inputs;
            
            %% scope extraction preperation
            obj.bst.sessions.(session).(measure).info.sc_ext_samples=((obj.bst.sessions.(session).(measure).inputs.prestim_scope_ext)+(obj.bst.sessions.(session).(measure).inputs.poststim_scope_ext))*5;
            obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples=(obj.bst.sessions.(session).(measure).inputs.prestim_scope_ext)*(-5);
            
            %% scope plotting preperation
            obj.bst.sessions.(session).(measure).info.sc_plot_last=(obj.bst.sessions.(session).(measure).inputs.poststim_scope_plt)*5;
            obj.bst.sessions.(session).(measure).info.sc_plot_first=(obj.bst.sessions.(session).(measure).inputs.prestim_scope_plt)*(5);
            obj.bst.sessions.(session).(measure).info.sc_plot_total=obj.bst.sessions.(session).(measure).info.sc_plot_last+obj.bst.sessions.(session).(measure).info.sc_plot_first;
            %% making time vector
            mep_plot_time_vector=1:obj.bst.sessions.(session).(measure).info.sc_plot_total;
            mep_plot_time_vector=mep_plot_time_vector./obj.bst.inputs.sc_samplingrate;
            mep_plot_time_vector=mep_plot_time_vector*1000;
            mep_plot_time_vector=mep_plot_time_vector+(((-1)*obj.bst.sessions.(session).(measure).info.sc_plot_first)/(obj.bst.sessions.(session).(measure).inputs.sc_samplingrate)*1000);
            obj.bst.sessions.(session).(measure).info.timevector=mep_plot_time_vector;
            
            obj.bst.sessions.(session).(measure).info.sc_plot_first=((obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)*-1)-obj.bst.sessions.(session).(measure).info.sc_plot_first;
            obj.bst.sessions.(session).(measure).info.sc_plot_last=((obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)*-1)+obj.bst.sessions.(session).(measure).info.sc_plot_last;
            
            
            if (length(obj.bst.inputs.iti)==2)
                jitter=(obj.bst.sessions.(session).(measure).inputs.iti(2)-obj.bst.sessions.(session).(measure).inputs.iti(1));
                iti=ones(1,obj.bst.sessions.(session).(measure).info.total_trials)*obj.bst.sessions.(session).(measure).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.bst.inputs.iti)==1)
                iti=ones(1,obj.bst.sessions.(session).(measure).info.total_trials)*(obj.bst.sessions.(session).(measure).inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.bst.sessions.(session).(measure).trials(:,2)=(round(iti,3))';
            obj.bst.sessions.(session).(measure).trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
            % onset offset MEP Amps
            obj.bst.sessions.(session).(measure).info.mep_onset_calib=obj.bst.inputs.mep_onset*5000;
            obj.bst.sessions.(session).(measure).info.mep_offset_calib=obj.bst.inputs.mep_offset*5000;
            
            obj.bst.sessions.(session).(measure).info.mep_onset_samp=abs(obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)+obj.bst.sessions.(session).(measure).info.mep_onset_calib;
            obj.bst.sessions.(session).(measure).info.mep_offset_samp=abs(obj.bst.sessions.(session).(measure).info.sc_ext_prepostsamples)+obj.bst.sessions.(session).(measure).info.mep_offset_calib;
            obj.par.(session).(measure).stop_event
            if(obj.par.(session).(measure).stop_event==1)
                disp('entered heree')
                total_trials=obj.bst.sessions.(session).(measure).info.trial_plotted;
                obj.bst.sessions.(session).(measure).results.mt=ceil(mean(obj.bst.sessions.(session).(measure).trials((total_trials-(obj.bst.inputs.mt_trialstoavg-1):total_trials),1)));
                obj.bst.sessions.(session).(measure).info.rmt=obj.bst.sessions.(session).(measure).results.mt;
                total_trials=[];
                obj.bst.sessions.(session).(measure).results.mt
                obj.pi.mt_ptc.result_mt.String=obj.bst.sessions.(session).(measure).results.mt;
                obj.par.(session).(measure).result_mt=obj.bst.sessions.(session).(measure).results.mt;
                
            end
            
            %% Font updating
            obj.bst.info.axes.mep
            obj.bst.info.axes.mep.FontSize=obj.bst.inputs.FontSize;
            %% Graph Y lim setting
            set(obj.bst.info.axes.mep,'YLim',[obj.bst.inputs.ylim_min obj.bst.inputs.ylim_max])
            y_ticks_mep=linspace(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_min,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.ylim_max,5);
            yticks(obj.bst.info.axes.mep,y_ticks_mep);
            
            %% Graph X lim setting
            xlim(obj.bst.info.axes.mep,[obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(1), obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)]);
            
            
            %% MEP search window setting
            delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
            mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
            mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
            mat=unique(sort([mat1 mat2]));
            mat=unique(mat);
            xticks(obj.bst.info.axes.mep,mat);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):0.25:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',1) ;
            
            
        end
        function cb_pi_mt_ptc_input_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device=obj.pi.mt_ptc.input_device.Value;
            obj.pi.mt_ptc.input_device.Value
            obj.pi.mt_ptc.input_device.String
            obj.pi.mt_ptc.input_device.Value
        end
        function cb_pi_mt_ptc_output_device(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device=obj.pi.mt_ptc.output_device.Value;
            obj.pi.mt_ptc.output_device.Value
        end
        function cb_pi_mt_ptc_display_scopes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).display_scopes=obj.pi.mt_ptc.display_scopes.String;
        end
        function cb_pi_mt_ptc_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.mt_ptc.target_muscle.String;
        end
        function cb_pi_mt_ptc_thresholding_method(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).thresholding_method_value=(obj.pi.mt_ptc.thresholding_method.Value);
        end
        function cb_pi_mt_ptc_mt_mv(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_mv=str2num(obj.pi.mt_ptc.mt_mv.String);
        end
        function cb_pi_mt_ptc_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=str2num(obj.pi.mt_ptc.trials_per_condition.String);
        end
        function cb_pi_mt_ptc_starting_stim_inten(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_starting_stim_inten=str2num(obj.pi.mt_ptc.mt_starting_stim_inten.String);
        end
        function cb_pi_mt_ptc_trials_to_avg(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg=str2num(obj.pi.mt_ptc.trials_to_avg.String);
        end
        function cb_pi_mt_ptc_iti(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.mt_ptc.iti.String);
        end
        function cb_pi_mt_ptc_mep_onset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset=str2num(obj.pi.mt_ptc.mep_onset.String);
        end
        function cb_pi_mt_ptc_mep_offset(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset=str2num(obj.pi.mt_ptc.mep_offset.String);
        end
        function cb_pi_mt_ptc_prestim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext=str2num(obj.pi.mt_ptc.prestim_scope_ext.String);
        end
        function cb_pi_mt_ptc_poststim_scope_ext(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext=str2num(obj.pi.mt_ptc.poststim_scope_ext.String);
        end
        function cb_pi_mt_ptc_prestim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt=str2num(obj.pi.mt_ptc.prestim_scope_plt.String);
        end
        function cb_pi_mt_ptc_poststim_scope_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt=str2num(obj.pi.mt_ptc.poststim_scope_plt.String);
        end
        function cb_pi_mt_ptc_ylim_min(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min=str2num(obj.pi.mt_ptc.ylim_min.String);
        end
        function cb_pi_mt_ptc_ylim_max(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max=str2num(obj.pi.mt_ptc.ylim_max.String);
        end
        function cb_pi_mt_ptc_FontSize(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize=str2num(obj.pi.mt_ptc.FontSize.String);
        end
        function cb_pi_mt_ptc_trials_for_mean_annotation(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation=str2num(obj.pi.mt_ptc.trials_for_mean_annotation.String);
        end
        function cb_pi_mt_ptc_trials_reset(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.trials_for_mean_annotation=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed_counter=0;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.reset_pressed=1;
        end
        function cb_pi_mt_ptc_plot_reset(obj)
            delete(obj.bst.info.handles.mean_mep_plot)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
        end
        function cb_pi_mt_ptc_save_plt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).save_plt=obj.pi.mt_ptc.save_plt.Value;
        end
        function cb_pi_mt_ptc_result_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).result_mt=str2num(obj.pi.mt_ptc.result_mt.String);
        end
        
        function cb_pr_mep_export(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','mep');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_mep_posthoc();
            
            
        end
        function cb_pr_hotspot_export_mepplot(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','mep');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_hotspot_posthoc();
        end
        function cb_pr_mt_export_mepplot(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            
            axes( 'Parent', figg,'Units','normalized','Tag','mep');
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.bst.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.info.event.mep_plot_ph=1;
            obj.bst.best_posthoc_mep_plot;
        end
        function cb_pr_mt_export_mtplot(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','rmt');
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.bst.info.axes.mt=findobj( panelhandle,'Type','axes','Tag','rmt');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_posthoc_mt_plot;
            axes(obj.bst.info.axes.mt);
            str_mt1='Motor Threshold (%MSO): ';
            str_mt2=num2str(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).results.mt);
            str_mt=[str_mt1 str_mt2];
            y_lim=max(ylim)+1;
            x_lim=mean(xlim)-3;
            obj.bst.info.handles.annotated_trialsNo=text(x_lim, y_lim,str_mt,'FontSize',obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.FontSize);
            
        end
        function cb_pr_ioc_export_mepplot(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','mep');
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.bst.info.axes.mep=findobj( panelhandle,'Type','axes','Tag','mep');
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_posthoc_mep_plot;
        end
        function cb_pr_ioc_export_scatplot(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','ioc');
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            obj.bst.info.axes.ioc_first=findobj( panelhandle,'Type','axes','Tag','ioc');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_posthoc_ioc_scatplot;
        end
        function cb_pr_ioc_export_iocfit(obj)
            exp=obj.pmd.exp_title.editfield.String; exp(exp == ' ') = '_';
            sub=obj.pmd.sub_code.editfield.String; sub(sub == ' ') = '_';
            sess=obj.info.event.current_session;
            meas=obj.info.event.current_measure_fullstr;
            plt='MEP_Plot';
            timestr=clock; times1=timestr(4);times2=timestr(5); time=[times1 times2]; time=num2str(time); time(time == ' ') = '_';
            file_name=[exp '_' sub '_' sess '_' meas '_' plt '_' time];
            figg=figure('Name',file_name,'NumberTitle','off');
            axes( 'Parent', figg,'Units','normalized','Tag','rmt');
            figHandle = findobj('Tag','umi1');
            panelhandle=findobj(figHandle,'Type','axes');
            
            obj.bst.info.axes.ioc_second=findobj( panelhandle,'Type','axes','Tag','ioc_fit');
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.best_ioc_fit;
            obj.bst.best_ioc_plot;
        end
        
        
        
        function cb_pi_eegtms_output_device	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).output_device	=	obj.pi.eegtms.output_device.String;
            
        end
        
        function cb_pi_eegtms_input_device	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).input_device	=	obj.pi.eegtms.input_device.String;
            
        end
        
        function cb_pi_eegtms_target_montage	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_montage	=	obj.pi.eegtms.target_montage.String;
            
        end
        
        function cb_pi_eegtms_freq_ist	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).freq_ist	=str2num(	obj.pi.eegtms.freq_ist.String);
            
        end
        
        function cb_pi_eegtms_fre1_2nd	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).fre1_2nd	=str2num(	obj.pi.eegtms.fre1_2nd.String);
            
        end
        
        function cb_pi_eegtms_target_phase	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_phase	=str2num(	obj.pi.eegtms.target_phase.String);
            
        end
        
        function cb_pi_eegtms_amp_low	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_low	=str2num(	obj.pi.eegtms.amp_low.String);
            
        end
        
        function cb_pi_eegtms_amp_hi	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).amp_hi	=str2num(	obj.pi.eegtms.amp_hi.String);
            
        end
        
        function cb_pi_eegtms_offset_samples	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).offset_samples	=str2num(	obj.pi.eegtms.offset_samples.String);
            
        end
        
        function cb_pi_eegtms_stimulation_intensities	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities	=str2num(	obj.pi.eegtms.stimulation_intensities.String);
            
        end
        
        function cb_pi_eegtms_trials_per_condition	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition	=str2num(	obj.pi.eegtms.trials_per_condition.String);
            
        end
        
        function cb_pi_eegtms_iti	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti	=str2num(	obj.pi.eegtms.iti.String);
            
        end
        function cb_pi_eegtms_phase_tolerance	(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).phase_tolerance	=str2num(	obj.pi.eegtms.phase_tolerance.String);
            
        end
        
        
        
        
        
        function disable_listboxes(obj)
            obj.pmd.lb_measures.listbox.Enable='off';
            obj.pmd.lb_sessions.listbox.Enable='off';
        end
        function enable_listboxes(obj)
            obj.pmd.lb_measures.listbox.Enable='on';
            obj.pmd.lb_sessions.listbox.Enable='on';
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
        
        %         function best_num2word(obj)
        %             switch obj.par.axesno
        %                 case 1
        %                     obj.par.axesno_word=
        %         end
        %
    end
    
    %method end
end



%main panel is the panel on which measurement designer, inputs panel and results panel are placed
% all panels have p infront of their names
% md- measurement designer
