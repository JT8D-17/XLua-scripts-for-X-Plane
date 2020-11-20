function Widget_Init()
    if XPWidgets ~= nil then
    
        Widget_ID = XPWidgets.XPCreateWidget(0,500,1000,0,0,"Test Widget",1,nil,0) -- Left, Top, Right, Bottom, Visible, Descriptor, Root, Container, Class
        
        print("PropAutoAdjust widget initialized!")
    end
end
