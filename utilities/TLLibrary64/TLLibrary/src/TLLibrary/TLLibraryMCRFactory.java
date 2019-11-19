/*
 * MATLAB Compiler: 4.17 (R2012a)
 * Date: Thu Jun 11 10:10:15 2015
 * Arguments: "-B" "macro_default" "-W" "java:TLLibrary,TransferLearning" "-T" "link:lib" 
 * "-d" "D:\\chengxh\\matlab\\TLLibrary64\\TLLibrary\\src" "-w" 
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w" 
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w" "enable:demo_license" 
 * "-v" 
 * "class{TransferLearning:D:\\chengxh\\matlab\\TLLibrary64\\CASO_MVMT_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\CCR3_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\CDPLSA_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\CRA_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\getSigmoid.m,D:\\chengxh\\matlab\\TLLibrary64\\HIDC_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\IHR_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\MAMUDA_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\MTrick_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\TLDA_enterFunc.m,D:\\chengxh\\matlab\\TLLibrary64\\TriTL_enterFunc.m}" 
 */

package TLLibrary;

import com.mathworks.toolbox.javabuilder.*;
import com.mathworks.toolbox.javabuilder.internal.*;

/**
 * <i>INTERNAL USE ONLY</i>
 */
public class TLLibraryMCRFactory
{
   
    
    /** Component's uuid */
    private static final String sComponentId = "TLLibrary_4E73E4E2BF4AB4DA5088A0784DE6A6B6";
    
    /** Component name */
    private static final String sComponentName = "TLLibrary";
    
   
    /** Pointer to default component options */
    private static final MWComponentOptions sDefaultComponentOptions = 
        new MWComponentOptions(
            MWCtfExtractLocation.EXTRACT_TO_CACHE, 
            new MWCtfClassLoaderSource(TLLibraryMCRFactory.class)
        );
    
    
    private TLLibraryMCRFactory()
    {
        // Never called.
    }
    
    public static MWMCR newInstance(MWComponentOptions componentOptions) throws MWException
    {
        if (null == componentOptions.getCtfSource()) {
            componentOptions = new MWComponentOptions(componentOptions);
            componentOptions.setCtfSource(sDefaultComponentOptions.getCtfSource());
        }
        return MWMCR.newInstance(
            componentOptions, 
            TLLibraryMCRFactory.class, 
            sComponentName, 
            sComponentId,
            new int[]{7,17,0}
        );
    }
    
    public static MWMCR newInstance() throws MWException
    {
        return newInstance(sDefaultComponentOptions);
    }
}
