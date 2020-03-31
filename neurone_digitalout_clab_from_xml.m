function digitalout_clab = neurone_digitalout_clab_from_xml(protocolXmlDoc)
% protocolXmlDoc - exported NeurOne XML protocol (used to extract digital out channels)
% Example: neurone_digitalout_clab_from_xml(xmlread('FRONTHETA v2.xml'))

    % parse the NeurOne protocol in order to determine the realtime out channels
    
    inputIdNameMap = containers.Map;
    allInputElements = protocolXmlDoc.getElementsByTagName('DataSetProtocol').item(0).getElementsByTagName('TableProtocolInput');
    for k = 0:allInputElements.getLength-1
       thisElement = allInputElements.item(k);
       inputName = thisElement.getElementsByTagName('Name').item(0).getFirstChild.getData;
       %inputNumber = thisElement.getElementsByTagName('InputNumber').item(0).getFirstChild.getData;
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

end