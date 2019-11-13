classdef BEST < handle
    properties
        par
        
       
        
        
    end
    
    properties (Hidden)
         pmd %panel_measurement_designer
        pi  %panel_inputs
        pr %panel_results
        bst
         info
        data
        
        
          var
        grid % bottom most 3 panels
        panel
        pulse
        a1
        a2
        
        
        vp
        mrtms_panel_stimulation_paradigm
        mep_panel_update_btn
        mep_panel_run_btn
        mep_panel_stop_btn
        %         inputs
        axesH
        
        fig
        menu
     
        
    end
    
    methods
        
        function obj=BEST()
            
            obj.create_gui;
        end
        
        
        function create_gui(obj)
            obj.create_best_obj;
            obj.create_figure;
            obj.create_menu;
            obj.create_main_panel;
            obj.create_inputs_panel;
            obj.create_results_panel;
            %               obj.pi_ioc
            %  obj.pr_mep
            
        end
        
        function create_best_obj(obj)
            obj.bst= best_toolbox_gui_version_inprogress_testinlab_2910_sim (obj);
        end
        
        function create_figure(obj)
            obj.fig.handle = figure('Tag','umi1','ToolBar','none','MenuBar','none','Name','BEST Toolbox','NumberTitle','off');
            
            obj.info.session_no=0;
            obj.info.measurement_no=0;
            obj.info.event.current_session={};
            obj.info.event.current_measure={};
            obj.info.session_matrix={};
            
            % set(fig, 'Position', get(0, 'Screensize'));
            set(obj.fig.handle,'Units','normalized', 'Position', [0 0 1 1]);
            
            
            obj.pr.mep.axes1=axes;
            obj.pr.hotspot.axes1=axes;
            obj.pr.mt.axes_mep=axes;
            obj.pr.mt.axes_mtplot=axes;
            obj.pr.ioc.axes_mep=axes;
            obj.pr.ioc.axes_scatplot=axes;
            obj.pr.ioc.axes_fitplot=axes;
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
            uiextras.HBox( 'Parent', menu_hbox,'Spacing', 5, 'Padding', 5 );
            set(menu_hbox,'Widths',[-1 -1 -2 -1.8 -1.5 -10]);
            
            
            obj.info.menu.md=0;
            obj.info.menu.ip=0;
            obj.info.menu.rp=0;
            
            
        end
        
        function create_main_panel(obj)
            obj.fig.main = uix.GridFlex( 'Parent', obj.fig.vbox, 'Spacing', 5 );
            set(obj.fig.vbox,'Heights',[-1 -25]);
            p_measurement_designer = uix.Panel( 'Parent', obj.fig.main, 'Padding', 5,  'Units','normalized','BorderType','none');
            obj.pmd.panel = uix.Panel( 'Parent', p_measurement_designer, 'Title', 'Measurement Designer', 'Padding', 5,'FontSize',14 ,'Units','normalized','FontWeight','bold','TitlePosition','centertop');
            pmd_vbox = uix.VBox( 'Parent', obj.pmd.panel, 'Spacing', 5, 'Padding', 5  );
            
            % experiment title: first horizontal row in measurement designer panel
            pmd_hbox_exp_title = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_exp_title,'String','Experiment Title:','FontSize',11,'HorizontalAlignment','left','Units','normalized' );
            obj.pmd.exp_title.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_exp_title ,'FontSize',11);
            obj.pmd.exp_title.btn=uicontrol( 'Parent', pmd_hbox_exp_title ,'Style','PushButton','String','...','FontWeight','Bold','Callback',@obj.opendir );
            set( pmd_hbox_exp_title, 'Widths', [120 -0.7 -0.09]);
            
            % subject code: second horizontal row on first panel
            pmd_hbox_sub_code = uix.HBox( 'Parent', pmd_vbox, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', pmd_hbox_sub_code,'String','Subject Code:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pmd.sub_code.editfield=uicontrol( 'Style','edit','Parent', pmd_hbox_sub_code ,'FontSize',11);
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
            obj.pmd.select_measure.string={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','MEP Dose Response Curve_sp','MEP Dose Response Curve_pp','EEG triggered TMS','TMS fMRI','TEP Measurement'};
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
            mus1 = uimenu(m_sessions,'label','Copy');
            mus2 = uimenu(m_sessions,'label','Paste Above');
            mus3 = uimenu(m_sessions,'label','Paste Below');
            mus4 = uimenu(m_sessions,'label','Delete');
            obj.pmd.lb_sessions.listbox=uicontrol( 'Style','listbox','Parent', pmd_vbox ,'FontSize',11,'String',obj.pmd.lb_sessions.string,'uicontextmenu',m_sessions,'Callback',@(~,~)obj.cb_session_listbox);
            
            %empty 8th horizontal row on first panel
            uicontrol( 'Style','text','Parent', pmd_vbox,'String','Protocol','FontSize',12,'HorizontalAlignment','center' ,'Units','normalized','FontWeight','bold');
            
            %measurement listbox: 9th horizontal row on first panel
            %             measure_lb2={'MEP Measurement','MEP Hotspot Search','MEP Motor Threshold Hunting','Dose-Response Curve (MEP-sp)','Dose-Response Curve (MEP-pp)','EEG triggered TMS','MR triggered TMS','TEP Measurement'};
            obj.pmd.lb_measures.string={};
            m=uicontextmenu(obj.fig.handle);
            mu1 = uimenu(m,'label','Copy');
            mu2 = uimenu(m,'label','Paste Above');
            mu3 = uimenu(m,'label','Paste Below');
            mu4 = uimenu(m,'label','Delete');
            mu5 = uimenu(m,'label','Help');
            obj.pmd.lb_measures.listbox=uicontrol( 'Style','listbox','Parent', pmd_vbox ,'FontSize',11,'String',obj.pmd.lb_measures.string,'uicontextmenu',m,'ButtonDownFcn',@bdf_t,'Callback',@(~,~)obj.cb_measure_listbox);
            m=uicontextmenu(obj.fig.handle);
            
            
            set( pmd_vbox, 'Heights', [-0.05 -0.05 -0.05 -0.05 0 -0.04 -0.11 -0.04 -0.63]);
            
        end
        
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
        
        function pi_mep(obj)
            obj.pi.mep.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','MEP Measurement' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mep.vb = uix.VBox( 'Parent', obj.pi.mep.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mep.vb,'Spacing', 5, 'Padding', 5 );
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mep_target_muscle); %,'Callback',@obj.cb_mep_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
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
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_mep_mep_onset);
            obj.pi.mep.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_mep_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
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
            obj.pi.mep.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Callback',@(~,~)obj.cb_pi_mep_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mep_ylim_max);
            obj.pi.mep.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mep_ylim_min);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_mep_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
              % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mep.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_mep_trials_for_mean_annotation);
            obj.pi.mep.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_mep_trials_reset);
            obj.pi.mep.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Plot','Callback',@(~,~)obj.cb_pi_mep_plot_reset);

            set( mep_panel_15, 'Widths', [150 -1 -2 -2]);

            
            uiextras.HBox( 'Parent', obj.pi.mep.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mep.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mep.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_update)
            obj.pi.mep.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mep_run);
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            set(obj.pi.mep.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.1 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.5])
            
            
        end
        
        function pi_hotspot(obj)
            obj.pi.hotspot.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Hotspot Search' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.hotspot.vb = uix.VBox( 'Parent', obj.pi.hotspot.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.hotspot.vb,'Spacing', 5, 'Padding', 5 )
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_target_muscle); %,'Callback',@obj.cb_hotspot_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_stimulation_intensities);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
            % row 4
            mep_panel_row4 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row4,'String','Trials per Condition:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.trials_per_condition=uicontrol( 'Style','edit','Parent', mep_panel_row4 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_trials_per_condition);
            set( mep_panel_row4, 'Widths', [150 -2]);
            
            %row 5
            mep_panel_row5 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row5,'String','Inter Trial Interval (s):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.iti=uicontrol( 'Style','edit','Parent', mep_panel_row5 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_hotspot_iti);
            set( mep_panel_row5, 'Widths', [150 -2]);
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.hotspot.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.hotspot.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_hotspot_mep_onset);
            obj.pi.hotspot.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %row 9
            mep_panel_row10 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_prestim_scope_ext);
            obj.pi.hotspot.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_hotspot_poststim_scope_ext);
            set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_hotspot_prestim_scope_plt);
            obj.pi.hotspot.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_hotspot_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_hotspot_ylim_max);
            obj.pi.hotspot.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_hotspot_ylim_min);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_hotspot_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.hotspot.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_hotspot_trials_for_mean_annotation);
            obj.pi.hotspot.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_hotspot_trials_reset);
            obj.pi.hotspot.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_15 ,'FontSize',10,'String','Reset Plot','Callback',@(~,~)obj.cb_pi_hotspot_plot_reset);

            set( mep_panel_15, 'Widths', [150 -1 -2 -2]);
            
            uiextras.HBox( 'Parent', obj.pi.hotspot.vb);
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.hotspot.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.hotspot.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_hotspot_update);
            obj.pi.hotspot.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_hotspot_run);
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            set(obj.pi.hotspot.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -1 -0.5])
            
            
        end
        
        function pi_mt(obj)
            obj.pi.mt.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','Motor Threshold Hunting' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.mt.vb = uix.VBox( 'Parent', obj.pi.mt.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.mt.vb,'Spacing', 5, 'Padding', 5 )
            mep_panel_row1 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row1,'String','Thresholding Method:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.thresholding_method=uicontrol( 'Style','popupmenu','Parent', mep_panel_row1 ,'FontSize',11,'String',{'PEST Pentland', 'PEST Taylor'},'Callback',@(~,~)obj.cb_pi_mt_thresholding_method);
            set( mep_panel_row1, 'Widths', [150 -2]);
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.mt.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_mt_target_muscle); %,'Callback',@obj.cb_mt_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
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
            obj.pi.mt.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_mt_ylim_max);
            obj.pi.mt.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_mt_ylim_min);
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
            obj.pi.mt.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Plot','Callback',@(~,~)obj.cb_pi_mt_plot_reset);

            set( mep_panel_16, 'Widths', [150 -1 -2 -2]);
            
            
            uiextras.HBox( 'Parent', obj.pi.mt.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.mt.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.mt.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_update);
            obj.pi.mt.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_mt_run);
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            set(obj.pi.mt.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.5])
            
            
        end
        
        function pi_ioc(obj)
            obj.pi.ioc.panel=uix.Panel( 'Parent', obj.pi.empty_panel,'FontSize',14 ,'Units','normalized','Title','MEP IOC (SP)' ,'FontWeight','Bold','TitlePosition','centertop');
            obj.pi.ioc.vb = uix.VBox( 'Parent', obj.pi.ioc.panel, 'Spacing', 5, 'Padding', 5  );
            
            % row 1
            uiextras.HBox( 'Parent', obj.pi.ioc.vb,'Spacing', 5, 'Padding', 5 )
            
            
            % row 2
            mep_panel_row2 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row2,'String','Target Muscle:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.target_muscle=uicontrol( 'Style','edit','Parent', mep_panel_row2 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_target_muscle); %,'Callback',@obj.cb_ioc_target_muscle
            set( mep_panel_row2, 'Widths', [150 -2]);
            
            % row 3
            mep_panel_row3 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row3,'String','Stimulation Intensities:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.stimulation_intensities=uicontrol( 'Style','edit','Parent', mep_panel_row3 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_stimulation_intensities);
            set( mep_panel_row3, 'Widths', [150 -2]);
            
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
            
            % row 6
            uiextras.HBox( 'Parent', obj.pi.ioc.vb)
            
            % row 7
            uicontrol( 'Style','text','Parent',  obj.pi.ioc.vb,'String','Advanced Settings','FontSize',10,'HorizontalAlignment','center','Units','normalized','ForegroundColor',[0.5 0.5 0.5]);
            
            %row 8
            mep_panel_row8 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row8,'String','MEP onset (ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.mep_onset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','15','Callback',@(~,~)obj.cb_pi_ioc_mep_onset);
            obj.pi.ioc.mep_offset=uicontrol( 'Style','edit','Parent', mep_panel_row8 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_mep_offset);
            set( mep_panel_row8, 'Widths', [150 -2 -2]);
            
            
            %row 9
            mep_panel_row10 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row10,'String','Pre/Poststim. Scope Extract(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.prestim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_prestim_scope_ext);
            obj.pi.ioc.poststim_scope_ext=uicontrol( 'Style','edit','Parent', mep_panel_row10 ,'FontSize',11,'String','50','Callback',@(~,~)obj.cb_pi_ioc_poststim_scope_ext);
            set( mep_panel_row10, 'Widths', [150 -2 -2]);
            
            %row 11
            mep_panel_row11 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row11,'String','Pre/Poststim. Scope Plot(ms):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.prestim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_prestim_scope_plt);
            obj.pi.ioc.poststim_scope_plt=uicontrol( 'Style','edit','Parent', mep_panel_row11 ,'FontSize',11,'String','150','Callback',@(~,~)obj.cb_pi_ioc_poststim_scope_plt);
            set( mep_panel_row11, 'Widths', [150 -2 -2]);
            
            % row 12
            mep_panel_row12 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_ioc_units_mso);
            obj.pi.ioc.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_ioc_units_mt);
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_ioc_mt);
            obj.pi.ioc.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Callback',@(~,~)obj.cb_pi_ioc_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            % row 15
            mep_panel_15 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_15,'String','Y Axis Max/Min (microV):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.ylim_max=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','8000','Callback',@(~,~)obj.cb_pi_ioc_ylim_max);
            obj.pi.ioc.ylim_min=uicontrol( 'Style','edit','Parent', mep_panel_15 ,'FontSize',11,'String','-8000','Callback',@(~,~)obj.cb_pi_ioc_ylim_min);
            set( mep_panel_15, 'Widths', [150 -2 -2]);
            
            
            % row 14
            mep_panel_14 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_14,'String','Font Size:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.FontSize=uicontrol( 'Style','edit','Parent', mep_panel_14 ,'FontSize',11,'String','12','Callback',@(~,~)obj.cb_pi_ioc_FontSize);
            set( mep_panel_14, 'Widths', [150 -2]);
            
                          % row 16
            mep_panel_16 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_16,'String','Trials No for Mean MEP Amp:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.ioc.trials_for_mean_annotation=uicontrol( 'Style','edit','Parent', mep_panel_16 ,'FontSize',11,'String','5','Callback',@(~,~)obj.cb_pi_ioc_trials_for_mean_annotation);
            obj.pi.ioc.trials_annotated_reset=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Mean','Callback',@(~,~)obj.cb_pi_ioc_trials_reset);
            obj.pi.ioc.trials_annotated_reset_plot=uicontrol( 'Style','PushButton','Parent', mep_panel_16 ,'FontSize',10,'String','Reset Plot','Callback',@(~,~)obj.cb_pi_ioc_plot_reset);

            set( mep_panel_16, 'Widths', [150 -1 -2 -2]);
            
            uiextras.HBox( 'Parent', obj.pi.ioc.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.ioc.vb, 'Spacing', 5, 'Padding', 5  );
            obj.pi.ioc.update=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_ioc_update);
            obj.pi.ioc.run=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@(~,~)obj.cb_pi_ioc_run);
            obj.pi.stop=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@(~,~)obj.stop,'Enable','on');
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            set(obj.pi.ioc.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 -0.4 0 -0.5])
            
            
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
            mep_panel_row12 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_row12,'String','Intensity Units:','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.units_mso=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MSO','Value',1,'Callback',@(~,~)obj.cb_pi_tmsfmri_units_mso);
            obj.pi.tmsfmri.units_mt=uicontrol( 'Style','radiobutton','Parent', mep_panel_row12 ,'FontSize',11,'String','%MT','Callback',@(~,~)obj.cb_pi_tmsfmri_units_mt);
            set( mep_panel_row12, 'Widths', [200 -2 -2]);
            
            % row 13
            mep_panel_13 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            uicontrol( 'Style','text','Parent', mep_panel_13,'String','Motor Threshold (%MSO):','FontSize',11,'HorizontalAlignment','left','Units','normalized');
            obj.pi.tmsfmri.mt=uicontrol( 'Style','edit','Parent', mep_panel_13 ,'FontSize',11,'Callback',@(~,~)obj.cb_pi_tmsfmri_mt);
            obj.pi.tmsfmri.mt_btn=uicontrol( 'Style','pushbutton','Parent', mep_panel_13 ,'FontSize',11,'String','Measure','Callback',@(~,~)obj.cb_pi_tmsfmri_mt_btn);
            set( mep_panel_13, 'Widths', [175 -2 -2]);
            
            
            
            uiextras.HBox( 'Parent', obj.pi.tmsfmri.vb)
            
            mep_panel_17 = uix.HBox( 'Parent', obj.pi.tmsfmri.vb, 'Spacing', 5, 'Padding', 5  );
            obj.mep_panel_update_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Update','FontWeight','Bold','Callback',@obj.rcb_btn)
            obj.mep_panel_run_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Run','FontWeight','Bold','Callback',@obj.rcb)
            obj.mep_panel_stop_btn=uicontrol( 'Parent', mep_panel_17 ,'Style','PushButton','String','Stop','FontWeight','Bold','Callback',@obj.stop,'Enable','on')
            set( mep_panel_17, 'Widths', [-2 -4 -2]);
            
            set(obj.pi.tmsfmri.vb,'Heights',[-0.1 -0.4 -0.4 -0.4 -0.4 -0.4 -0.2 -0.2 -0.4 -0.4 -1.5 -0.5])
            
            
        end
        
        
        
        
        
        
        
        
        
        
        
        %% results panel
        
        function create_results_panel(obj)
            obj.pr.empty_panel= uix.Panel( 'Parent', obj.fig.main, 'Padding', 5 ,'Units','normalized','BorderType','none' );
            uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            set( obj.fig.main, 'Widths', [-1.15 -1.35 -2] );
        end
        
        function pr_mep(obj)
            obj.pr.mep.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            
            obj.pr.mep.axes1=axes( 'Parent', obj.pr.mep.handle,'Units','normalized','Tag','mep');
            
            
            % % % % % % % % % % %             set(obj.pr.mep.axes1,'Visible', 'off');
        end
        
        function pr_hotspot(obj)
            obj.pr.hotspot.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            
            obj.pr.hotspot.axes1=axes( 'Parent', obj.pr.hotspot.handle,'Units','normalized','Tag','mep');
        end
        
        function pr_mt(obj)
            
            
            obj.pr.mt.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            obj.pr.mt.hbox=uix.HBoxFlex( 'Parent', obj.pr.mt.handle, 'Padding', 5 ,'Units','normalized' );
            obj.pr.mt.panel_mep= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.mt.panel_mtplot= uix.Panel( 'Parent', obj.pr.mt.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live Intensity Trace','FontSize',12,'TitlePosition','centertop' );
            
            obj.pr.mt.axes_mep=axes( 'Parent',  obj.pr.mt.panel_mep,'Units','normalized','Tag','mep');
            obj.pr.mt.axes_mtplot=axes( 'Parent',obj.pr.mt.panel_mtplot,'Units','normalized','Tag','rmt');
            set(obj.pr.mt.hbox,'Widths',[-1 -1])
            
            
        end
        
        
        function pr_ioc(obj)
            
            
            obj.pr.ioc.handle= uix.Panel( 'Parent', obj.pr.empty_panel, 'Padding', 5 ,'Units','normalized','Title', 'Results','FontWeight','bold','FontSize',14,'TitlePosition','centertop' );
            tab = uiextras.TabPanel( 'Parent', obj.pr.ioc.handle, 'Padding', 5 );
            
            
            obj.pr.ioc.hbox=uix.HBoxFlex( 'Parent', tab, 'Padding', 5 ,'Units','normalized' );
            obj.pr.ioc.panel_mep= uix.Panel( 'Parent', obj.pr.ioc.hbox, 'Padding', 5 ,'Units','normalized','Title', 'Live MEP Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ioc.panel_scatplot= uix.Panel( 'Parent', obj.pr.ioc.hbox, 'Padding', 5 ,'Units','normalized','Title', 'MEP P2P Scatt Plot','FontSize',12,'TitlePosition','centertop' );
            obj.pr.ioc.panel_fitplot= uix.Panel( 'Parent', tab, 'Padding', 5 ,'Units','normalized','Title', 'Fitted Dose-Response Curve','FontSize',12,'TitlePosition','centertop' );
            
            
            obj.pr.ioc.axes_mep=axes( 'Parent',  obj.pr.ioc.panel_mep,'Units','normalized','Tag','mep');
            obj.pr.ioc.axes_scatplot=axes( 'Parent',obj.pr.ioc.panel_scatplot,'Units','normalized','Tag','ioc');
            obj.pr.ioc.axes_fitplot=axes( 'Parent',obj.pr.ioc.panel_fitplot,'Units','normalized','Tag','ioc_fit');
            
            set(obj.pr.ioc.hbox,'Widths',[-1 -1])
            
            tab.TabNames={'Live Results','Fitted IOC'};
            tab.SelectedChild=1;
            tab.TabSize=200;
            tab.FontSize=12;
            
        end
        
        function cb_btn_menu_load(obj)
        end
        
        function cb_session_add(obj)
            obj.info.session_no=obj.info.session_no+1;
            
            session_name=obj.pmd.sess_title.editfield.String;
            session_name(session_name == ' ') = '_';
            
            
            
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
                session_name=[];
                
                
                
            else
                obj.info.session_no=obj.info.session_no-1;
                errordlg('Session exists already with this name, please choose another name if you wish to enter a session','BEST Toolbox');
            end
            
            obj.cb_session_listbox
            % obj.cb_measure_listbox
        end
        
        function cb_measure_add(obj)
            
            % %             obj.info.event.current_session=obj.pmd.lb_sessions.listbox.String(obj.pmd.lb_sessions.listbox.Value)
            % %             obj.info.event.current_session=obj.info.event.current_session{1}
            % %             obj.info.event.current_session(obj.info.event.current_session == ' ') = '_';
            
            obj.data.(obj.info.event.current_session).info.measurement_no=obj.data.(obj.info.event.current_session).info.measurement_no+1;
            obj.data.(obj.info.event.current_session).info.measurement_str(1,obj.data.(obj.info.event.current_session).info.measurement_no)=obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value);
            
            
            measure_name=obj.pmd.select_measure.string(obj.pmd.select_measure.popupmenu.Value);
            obj.data.(obj.info.event.current_session).info.measurement_str_original(1,obj.data.(obj.info.event.current_session).info.measurement_no)=measure_name;
            
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
            
            obj.info.event.current_measure_fullstr=obj.pmd.lb_measures.listbox.String(obj.pmd.lb_measures.listbox.Value);
            obj.info.event.current_measure_fullstr=obj.info.event.current_measure_fullstr{1};
            obj.info.event.current_measure_fullstr(obj.info.event.current_measure_fullstr == ' ') = '_';
            
            
            
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
                    obj.pi_mt;
                    obj.func_load_mt_par;
                case 'TMS fMRI'
                    obj.pi_tmsfmri;
                    obj.func_load_tmsfmri_par;
                    
                case 'MEP Dose Response Curve_sp'
                    obj.pi_ioc;
                    obj.func_load_ioc_par;
                otherwise
                    
                    disp('other value')
                    
            end
            % obj.info.event.current_measure(obj.info.event.current_measure == ' ') = '_';
            
            
            %  obj.func_load_par
            
            %                         current_measure=obj.info.event.current_measure;
            %           obj.inputs.mep.target_muscle.String=obj.data.(obj.info.event.current_session).(current_measure).mep.target_muscle
            
            
        end
        
        
        
        function func_create_defaults(obj)
            disp('defaults entered ------------------------------------------------------------------------')
            obj.info.defaults.target_muscle='APBr';
            obj.info.defaults.stimulation_intensities=[30 40 50 60 70 80];
            obj.info.defaults.trials_per_condition=[8];
            obj.info.defaults.iti=[3 5];
            obj.info.defaults.mep_onset=15;
            obj.info.defaults.mep_offset=50;
            obj.info.defaults.prestim_scope_ext=50;
            obj.info.defaults.poststim_scope_ext=150;
            obj.info.defaults.prestim_scope_plt=20;
            obj.info.defaults.poststim_scope_plt=100;
            obj.info.defaults.units_mso=1;
            obj.info.defaults.units_mt=0;
            obj.info.defaults.mt='';
            %             obj.info.defaults.mt_btn
            obj.info.defaults.ylim_max=+2000;
            obj.info.defaults.ylim_min=-2000;
            obj.info.defaults.FontSize=14;
            
            obj.info.defaults.mt_mv=0.5;
            
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

            
            
            
            
            
            
            
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.measure_being_added)=obj.info.defaults
            
            
        end
        
        function func_load_par(obj)
            switch obj.info.event.current_measure
                case 'MEP Measurement'
                    
                    obj.func_load_mep_par;
                    
                    
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
            
        end
        
        function func_load_mep_par(obj)
            obj.pi.mep.target_muscle.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle);
            obj.pi.mep.stimulation_intensities.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities);
            obj.pi.mep.trials_per_condition.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition;
            obj.pi.mep.iti.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.pi.mep.mep_onset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_onset;
            obj.pi.mep.mep_offset.String=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mep_offset;
            obj.pi.mep.prestim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_ext);
            obj.pi.mep.poststim_scope_ext.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_ext);
            obj.pi.mep.prestim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).prestim_scope_plt);
            obj.pi.mep.poststim_scope_plt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).poststim_scope_plt);
            obj.pi.mep.units_mso.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso);
            obj.pi.mep.units_mt.Value=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt);
            obj.pi.mep.mt.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt);
            %             obj.pi.mep.mt_btn.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn);
            obj.pi.mep.ylim_max.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_max);
            obj.pi.mep.ylim_min.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ylim_min);
            obj.pi.mep.FontSize.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).FontSize);
            obj.pi.mep.trials_for_mean_annotation.String=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_for_mean_annotation);      
        end
        
        function func_load_hotspot_par(obj)
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

        end
        
        function func_load_ioc_par(obj)
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
        end
        
        
        function cb_pi_mep_run(obj)
            delete(obj.pr.mep.axes1)
            delete(obj.pr.hotspot.axes1)
            delete(obj.pr.mt.axes_mep)
            delete(obj.pr.mt.axes_mtplot)
            delete(obj.pr.ioc.axes_mep)
            delete(obj.pr.ioc.axes_scatplot)
            delete(obj.pr.ioc.axes_fitplot)
            
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            
            obj.pi.mep.run.Enable='off';
            obj.pi.mep.target_muscle.Enable='off';
            obj.pi.mep.units_mso.Enable='off';
            obj.pi.mep.units_mt.Enable='off';
            obj.pi.mep.mt.Enable='off';
            obj.pi.mep.mt_btn.Enable='off';
            obj.pi.mep.prestim_scope_ext.Enable='off';
            obj.pi.mep.poststim_scope_ext.Enable='off';
            
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso==1)
                obj.bst.inputs.stim_mode='MSO';
            else
                obj.bst.inputs.stim_mode='MT';
                obj.bst.inputs.mt_mso=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt;
            end
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

            obj.pr_mep;
%             try
          
              obj.bst.best_mep;   
             
%             catch
%                 disp('MEP Measurement Stopped | BEST Toolbox')
%             end
           
            
            
            
            
            
        end
        
        function cb_pi_mep_update(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx+1;
            str1=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx);
            str2='update_';
            str=[str2 str1];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).(str)=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=[];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials=[];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).rawdata=[];
            
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
            
            
            
        end
        
        
        function cb_pi_hotspot_run(obj)
            delete(obj.pr.mep.axes1)
            delete(obj.pr.hotspot.axes1)
            delete(obj.pr.mt.axes_mep)
            delete(obj.pr.mt.axes_mtplot)
            delete(obj.pr.ioc.axes_mep)
            delete(obj.pr.ioc.axes_scatplot)
            delete(obj.pr.ioc.axes_fitplot)
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            obj.pi.hotspot.run.Enable='off';
            obj.pi.hotspot.target_muscle.Enable='off';

            
            obj.pi.hotspot.prestim_scope_ext.Enable='off';
            obj.pi.hotspot.poststim_scope_ext.Enable='off';
            
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
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

            obj.pr_hotspot;
             try
          
            obj.bst.best_motorhotspot;
            catch
                disp('MEP Measurement Stopped | BEST Toolbox')
            end
        end
        
        function cb_pi_hotspot_update(obj)
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx+1;
            str1=num2str(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx);
            str2='update_';
            str=[str2 str1];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).(str)=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement);
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs=[];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials=[];
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).rawdata=[];
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
        end
        
        
        function cb_pi_mt_run(obj)
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
             try
          
            obj.bst.best_motorthreshold;
            catch
                disp('MEP Measurement Stopped | BEST Toolbox')
            end
        end
        
        function cb_pi_mt_update(obj)
            
obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=1;            
            
            obj.bst.inputs.mt_trialstoavg=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_to_avg;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
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
           

            if (length(obj.bst.inputs.iti)==2)
                jitter=(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.iti(2)-obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.iti(1));
                iti=ones(1,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.total_trials)*obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.iti(1);
                iti=iti+rand(1,length(iti))*jitter;
            elseif (length(obj.bst.inputs.iti)==1)
                iti=ones(1,obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.total_trials)*(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.iti(1));
            else
                error(' BEST Toolbox Error: Inter-Trial Interval (ITI) input vector must be a scalar e.g. 2 or a row vector with 2 elements e.g. [3 4]')
            end
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials(:,2)=(round(iti,3))';
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).trials(:,3)=(movsum(iti,[length(iti) 0]))';
            
            % onset offset MEP Amps
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_calib=obj.bst.inputs.mep_onset*5000;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_calib=obj.bst.inputs.mep_offset*5000;
            
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_samp=abs(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_onset_calib;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_samp=abs(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.sc_ext_prepostsamples)+obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.mep_offset_calib;
            
% % % % % % % % % % % % % % % % % % % % % % %             axes(obj.pr.mt.axes_mep)
% % % % % % % % % % % % % % % % % % % % % % %             delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
% % % % % % % % % % % % % % % % % % % % % % %             mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
% % % % % % % % % % % % % % % % % % % % % % %             mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
% % % % % % % % % % % % % % % % % % % % % % %             mat=unique(sort([mat1 mat2]));
% % % % % % % % % % % % % % % % % % % % % % %             mat=unique(mat);
% % % % % % % % % % % % % % % % % % % % % % %             xticks(mat);
% % % % % % % % % % % % % % % % % % % % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):5:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',20) ;
% % % % % % % % % % % % % % % % % % % % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=0;
            
            
        end
        
        function cb_pi_ioc_run(obj)
            delete(obj.pr.mep.axes1)
            delete(obj.pr.hotspot.axes1)
            delete(obj.pr.mt.axes_mep)
            delete(obj.pr.mt.axes_mtplot)
            delete(obj.pr.ioc.axes_mep)
            delete(obj.pr.ioc.axes_scatplot)
            delete(obj.pr.ioc.axes_fitplot)
            
            
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).info.update_idx=0;
            obj.pi.ioc.run.Enable='off';
            obj.pi.ioc.target_muscle.Enable='off';
            obj.pi.ioc.units_mso.Enable='off';
            obj.pi.ioc.units_mt.Enable='off';
            obj.pi.ioc.mt.Enable='off';
            obj.pi.ioc.mt_btn.Enable='off';
            obj.pi.ioc.iti.Enable='off';
            obj.pi.ioc.trials_per_condition.Enable='off';
            obj.pi.ioc.stimulation_intensities.Enable='off';
            obj.pi.ioc.prestim_scope_ext.Enable='off';
            obj.pi.ioc.poststim_scope_ext.Enable='off';
            obj.bst.inputs.current_session=obj.info.event.current_session;
            obj.bst.inputs.current_measurement=obj.info.event.current_measure_fullstr;
            obj.bst.inputs.stimuli=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities;
            obj.bst.inputs.iti=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti);
            obj.bst.inputs.trials=(obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition);
            if (obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso==1)
                obj.bst.inputs.stim_mode='MSO';
            else
                obj.bst.inputs.stim_mode='MT';
                obj.bst.inputs.mt_mso=obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt;
            end
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

            obj.pr_ioc;
          
            obj.bst.best_ioc;
           
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
            
% % % % % % % % % % % % % % % % % % % % % %             axes(obj.pr.ioc.axes_mep)
% % % % % % % % % % % % % % % % % % % % % %             delete(obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy);
% % % % % % % % % % % % % % % % % % % % % %             mat1=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.prestim_scope_plt*(-1):10:obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.poststim_scope_plt;
% % % % % % % % % % % % % % % % % % % % % %             mat2=[0 obj.bst.inputs.mep_onset*1000 obj.bst.inputs.mep_offset*1000 obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.timevector(end)];
% % % % % % % % % % % % % % % % % % % % % %             mat=unique(sort([mat1 mat2]));
% % % % % % % % % % % % % % % % % % % % % %             mat=unique(mat);
% % % % % % % % % % % % % % % % % % % % % %             xticks(mat);
% % % % % % % % % % % % % % % % % % % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.handle_gridxy=gridxy([0 (obj.bst.inputs.mep_onset*1000):5:(obj.bst.inputs.mep_offset*1000)],'Color',[219/255 246/255 255/255],'linewidth',20) ;
% % % % % % % % % % % % % % % % % % % % % % %             obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.update_event=0;
            
        end
        
        
        
        %% input callbacks
        
        function cb_pi_mep_target_muscle(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).target_muscle=obj.pi.mep.target_muscle.String;
        end
        function cb_pi_mep_stimulation_intensities(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=str2num(obj.pi.mep.stimulation_intensities.String);
        end
        function cb_pi_mep_trials_per_condition(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trials_per_condition=str2num(obj.pi.mep.trials_per_condition.String);
        end
        function cb_pi_mep_iti(obj)
            % %             global opps
            % %             opps
            % %  initiliaze the global variable and then name it as per the global name
            %             obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=eval(obj.pi.mep.iti.String);
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).iti=str2num(obj.pi.mep.iti.String);
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
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=str2num(obj.pi.mep.mt_btn.String);
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
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;


        end
        
        %% hitspot inputs callbacks
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
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
        end
        
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
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
         end

        %% ioc calbacks
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
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=str2num(obj.pi.ioc.mt_btn.String);
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
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_pressed=1;
            obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).inputs.plot_reset_idx=obj.bst.sessions.(obj.bst.inputs.current_session).(obj.bst.inputs.current_measurement).info.trial;
         end
        
        % tms fmri callbacks
        function cb_pi_tmsfmri_ta(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).ta=str2num(obj.pi.tmsfmri.ta.String);
        end
        function cb_pi_tmsfmri_stimulation_intensities(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).stimulation_intensities=str2num(obj.pi.tmsfmri.stimulation_intensities.String);
        end
        function cb_pi_tmsfmri_trigdelay(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).trigdelay=str2num(obj.pi.tmsfmri.trigdelay.String);
        end
        function cb_pi_tmsfmri_volumes_cond(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).volumes_cond=str2num(obj.pi.tmsfmri.volumes_cond.String);
        end
        function cb_pi_tmsfmri_totalvolumes(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).totalvolumes=str2num(obj.pi.tmsfmri.totalvolumes.String);
        end
        
        
        function cb_pi_tmsfmri_units_mso(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mso=str2num(obj.pi.tmsfmri.units_mso.Value);
        end
        
        function cb_pi_tmsfmri_units_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).units_mt=str2num(obj.pi.tmsfmri.units_mt.Value);
        end
        
        function cb_pi_tmsfmri_mt(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt=str2num(obj.pi.tmsfmri.mt.String);
        end
        
        function cb_pi_tmsfmri_mt_btn(obj)
            obj.par.(obj.info.event.current_session).(obj.info.event.current_measure_fullstr).mt_btn=str2num(obj.pi.tmsfmri.mt_btn.String);
        end
        
        
        function cb_menu_save(obj)
            exp_name=obj.pmd.exp_title.editfield.String;
            exp_name(exp_name == ' ') = '_';
            
            subj_code=obj.pmd.sub_code.editfield.String;
            subj_code(subj_code == ' ') = '_';
            
            save_str=[exp_name '_' subj_code]
            varr.par=obj.par
            varr.info=obj.info
            varr.data=obj.data
            varr.exp_name=exp_name;
            varr.subj_code=subj_code;
            varr.sess=obj.pmd.lb_sessions.string;
          
            
            
            %             save('C:\0. HARD DISK\BEST Toolbox\BEST-04.08\GUI\save',save_str,'obj')
            save(save_str,'varr')
            
            
            %% save the information from graphics handle into the par handle in a organized way and then save that par and then it ll be good to go without any of
        end
        
        function cb_menu_load(obj)
            
            [file,path] = uigetfile;
            load(file,'varr');
            obj.par=varr.par;
            obj.info=varr.info;
            obj.data=varr.data;
            obj.pmd.exp_title.editfield.String=varr.exp_name;
            obj.pmd.sub_code.editfield.String=varr.subj_code;
            
            obj.pmd.lb_sessions.listbox.String=varr.sess;
            obj.cb_session_listbox;
            
            
            %% MVP has been created, now just have to make a bit of resturcting so that no graphics handles are saved, when loaded into matlab, just also add a
            %             function of cb measurement listbox value change as that will update all the inputs
            %             automatically , also save the pmd stuff into pars so that it can be properly retrived
            %             , make the handles go out of par as thats not needed then just save and load par and
            %             refresh stuff BAM YOU GO
            
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
        
        function stop(obj)
            obj.bst.inputs.stop_event=1;

        end
        
        
        
        
    end
    
    
    
    
    
    
    
    
    %method end
end



%main panel is the panel on which measurement designer, inputs panel and results panel are placed
%just FYI
% all panels have p infront of their names
% md- measurement designer
