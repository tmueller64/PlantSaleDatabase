/*
 * PlantSale.java
 *
 * Created on March 6, 2006, 8:39 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package com.jj;

import java.util.ArrayList;
import java.util.SortedMap;
import jakarta.servlet.jsp.jstl.sql.Result;

/**
 *
 * @author Tom  Mueller
 */
public class PlantSale {
    
    public static int divideRoundUp(int a, int b) {
        int c = a / b;
        return c * b < a ? c + 1 : c;
    }
    
    public static String[] getContainedSellerGroups(String groupid, Result sgroups) {
        Integer sgroup = new Integer(groupid);
        SortedMap[] rows = sgroups.getRows();
        int rowcount = sgroups.getRowCount();
        ArrayList sgs = new ArrayList();
        sgs.add(sgroup);
        for (int i = 0; i < sgs.size(); i++) {
            for (int j = 0; j < rowcount; j++) {
                if (rows[j].get("insellergroupID").equals(sgs.get(i))) {
                    Integer newgroup = (Integer)rows[j].get("id");
                    if (!sgs.contains(newgroup)) {
                        sgs.add(newgroup);
                    }
                }
            }
        }
        String sgsstr[] = new String[sgs.size()];
        for (int i = 0; i < sgs.size(); i++) {
            sgsstr[i] = sgs.get(i).toString();
        }
        return sgsstr;
    }
    
    
    /** Creates a new instance of PlantSale */
    public PlantSale() {
    }
    
}
