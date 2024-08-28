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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.csv.CSVRecord;

/**
 *
 * @author Tom  Mueller
 */
public class PlantSale {
    
    public static int divideRoundUp(int a, int b) {
        int c = a / b;
        return c * b < a ? c + 1 : c;
    }
    
    public static String getNewUserName(Result users) {
        int rowCount = users.getRowCount();
        if (rowCount == 0) {
            return "user1";
        }
        SortedMap[] rows = users.getRows();
        Set<String> existingUserNames = new HashSet<>();
        for (SortedMap row : rows) {
            existingUserNames.add((String)row.get("username"));
        }
        int uid = 1;
        while (existingUserNames.contains("user" + uid)) {
            uid++;
        }
        return "user" + uid;
    }
    
    public static String[] getContainedSellerGroups(String groupid, Result sgroups) {
        Integer sgroup = Integer.valueOf(groupid);
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
    
    public static boolean contains(List<Integer> list, Integer value) {
        return list.contains(value);
    }
    
    private static final String COLUMN_COUNT_ERROR = "<p>Invalid number of columns (%d) in the input file. The file " +
            "must have the following columns:</p>";
    private static final String COLUMN_MISSING_ERROR = "<p>Column %s is missing. Required columns are:</p>";
    private static final String COLUMN_SPEC = "<ol>" + 
            "<li><b>Submission Date</b> - format: yyyy/mm/dd hh:mm:ss</li>" +
            "<li><b>Student Name for Credit</b> or <b>Student/Seller Name</b> - format: firstname lastname</li>" +
            "<li><b>My Products</b> or <b>Items for sale</b> - value consists of a list of products followed by a Total entry and a" +
            "Transaction ID. Each product " + 
            "starts with a # followed by the product number and a space. The product amount is the number " + 
            "between “Amount: “ and “ USD”. The product quantity is the number between “Quantity: “ and “)”. " + 
            "Other data in the product field such as the name of the product is ignored. The total amount is the " + 
            "number between “Total: $“ and “Transaction” The spaces shown here in quotes are significant. " +
            "The transaction ID is the value between “Transaction ID: ” and “==Payer“. It is possible for this " +
            "field to be split into two fields: <b>My Products: Products</b> and <b>My Products: Payer Info</b>, with the " +
            "transaction ID being in the payer info field.</li>" +
            "<li>If <b>Items for sale</b> is present, then the customer info is extracted from that field based on the following format: Payment InformationFirst Name:<i>fname</i>Last Name:<i>lname</i>AddressStreet:<i>street</i>City:<i>city</i>State:<i>state</i>Zip:<i>zip</i>Country:<i>country</i></li>" +
            "<li><b>First Name</b> - customer first name</li>" +
            "<li><b>Last Name</b> - customer last name</li>" +
            "<li><b>Street Address</b> - customer address</li>" +
            "<li><b>City</b> - customer city</li>" +
            "<li><b>State / Province</b> - customer state</li>" +
            "<li><b>Postal / Zip Code</b> - customer zip</li>" +
            "<li><b>E-mail</b> or <b>Customer Email</b> - customer email</li>" +
            "<li><b>Customer Phone Number</b> - format: all non-digits are ignored</li>" +
            "</ol>";
    
    public static ColumnMap parseCSVColumns(CSVRecord record) throws RuntimeException {
        ColumnMap columnMap = new ColumnMap();
        columnMap.setDate(findColumn(record, "Submission Date"));
        columnMap.setSeller(findColumn(record, "Student Name for Credit", "Student/Seller Name"));
        
        try {
            columnMap.setTransaction(findColumn(record, "My Products: Payer Info"));
            columnMap.setProducts(findColumn(record, "My Products: Products"));
        } catch (RuntimeException e) {
            columnMap.setProducts(findColumn(record, "My Products", "Items for sale"));
            columnMap.setTransaction(columnMap.getProducts());
        }
        try {
            columnMap.setCustomer(findColumn(record, "Items for sale"));
        } catch (RuntimeException e) {
            columnMap.setFirstName(findColumn(record, "First Name"));
            columnMap.setLastName(findColumn(record, "Last Name"));
            columnMap.setAddress(findColumn(record, "Street Address"));
            columnMap.setCity(findColumn(record, "City"));
            columnMap.setState(findColumn(record, "State"));
            columnMap.setZip(findColumn(record, "Zip Code"));
            columnMap.setCustomer(-1);
        }
        
        columnMap.setEmail(findColumn(record, "E-mail", "Customer Email"));
        columnMap.setPhone(findColumn(record, "Customer Phone Number"));
        return columnMap;
    }
    
    private static int findColumn(CSVRecord record, String... names) throws RuntimeException {
        String lowerNames[] = new String[names.length];
        for (int i = 0; i < names.length; i++) {
            lowerNames[i] = names[i].toLowerCase();
        }
        for (int i = 0; i < record.size(); i++) {
            String recordName = record.get(i).toLowerCase();
            for (String lowerName : lowerNames) {
                if (recordName.contains(lowerName)) {
                    return i;
                }
            }
        }
        throw new RuntimeException(String.format(COLUMN_MISSING_ERROR, 
                String.join(" or ", names)) + COLUMN_SPEC);
    }
    
    /* 
     * Returns an OrderInfo that contains information about the imported order.
    */
    public static OrderInfo parseCSVOrderData(ColumnMap columnMap, CSVRecord record, 
            Map<String, OrderProductInfo> saleProducts,
            Map<String, Integer> sellers, Map<String, Integer> customers, Set<String> existingTIDs) {
        
        if (record.size() <= columnMap.getMaxColumn()) {
            throw new RuntimeException(String.format(COLUMN_COUNT_ERROR, record.size()) + COLUMN_SPEC);
        }
        OrderInfo order = new OrderInfo();
        order.setId(record.getRecordNumber());
        // Submission Date,Student's Name for Credit,: Products,: Payer Info,: Payer Address,First Name,Last Name,
        // E-mail,Street Address,Street Address Line 2,City,State / Province,Postal / Zip Code,Country,Customer Phone Number (required)

        String dateStr = record.get(columnMap.getDate());
        String sellerStr = record.get(columnMap.getSeller()).trim();
        String productsStr = record.get(columnMap.getProducts());
        String transactStr = record.get(columnMap.getTransaction()).replaceAll("[\r\n]", "");
        
        String firstNameStr;
        String lastNameStr;
        String addressStr;
        String cityStr;
        String stateStr;
        String zipStr;
        if (columnMap.getCustomer() >= 0) {
            String custInfo = record.get(columnMap.getCustomer()).split("Payment Information")[1];
            firstNameStr = custInfo.replaceAll("^.*First Name:", "").replaceAll("Last Name:.*$", "");
            lastNameStr = custInfo.replaceAll("^.*Last Name:", "").replaceAll("E-Mail:.*$", "");
            addressStr = custInfo.replaceAll("^.*AddressStreet:", "").replaceAll("City:.*$", "");
            cityStr = custInfo.replaceAll("^.*City:", "").replaceAll("State:.*$", "");
            stateStr = custInfo.replaceAll("^.*State:", "").replaceAll("Zip:.*$", "");
            zipStr = custInfo.replaceAll("^.*Zip:", "").replaceAll("Country:.*$", "");
        } else {
            firstNameStr = record.get(columnMap.getFirstName());
            lastNameStr = record.get(columnMap.getLastName());
            addressStr = record.get(columnMap.getAddress());
            cityStr = record.get(columnMap.getCity());
            stateStr = record.get(columnMap.getState());
            zipStr = record.get(columnMap.getZip());
        }
        String emailStr = record.get(columnMap.getEmail());
        String phoneStr = record.get(columnMap.getPhone());
        
        String dateFormats[] = { "y/M/d H:m:s", "y-M-d H:m:s", "y/M/d", "y-M-d", "MMM d, yyyy" };
        for (String dateFormat : dateFormats) {
            try {
                Date date = new SimpleDateFormat(dateFormat).parse(dateStr);
                order.setDate(new SimpleDateFormat("yyyy-MM-dd").format(date));
                break;
            } catch (ParseException ex) {
                continue;
            }
        }
        if (order.getDate() == null || order.getDate().isEmpty()) {
            order.setError("Order has invalid date.");
        }
        
        order.setFirstName(truncateIfLongerThan(firstNameStr, 30));
        order.setLastName(truncateIfLongerThan(lastNameStr, 50));
        order.setAddress(truncateIfLongerThan(addressStr, 255));
        order.setCity(truncateIfLongerThan(cityStr, 50));
        order.setState(truncateIfLongerThan(stateStr, 20));
        order.setZip(truncateIfLongerThan(zipStr, 20));       
        order.setPhone(truncateIfLongerThan(phoneStr.replaceAll("[^0-9]", ""), 30));
        if (!order.getPhone().isEmpty() && customers.containsKey(order.getPhone())) {
            order.setCustId(customers.get(order.getPhone()).toString());
        }
        order.setEmail(truncateIfLongerThan(emailStr, 50));
        order.setSellerName(sellerStr);
        
        if (sellers.get(sellerStr) != null) {
            order.setSellerId(sellers.get(sellerStr));
        } else {
            // perform case-insensitive search
            for (String name : sellers.keySet()) {
                if (name.equalsIgnoreCase(sellerStr)) {
                    order.setSellerId(sellers.get(name));
                    break;
                }
            }
            // if still not found, search for single matching case-insensitive substring
            if (order.getSellerId() == null || order.getSellerId() == 0) {
                String foundName = null;
                for (String name : sellers.keySet()) {
                    if (name.toLowerCase().contains(sellerStr.toLowerCase()) ||
                        sellerStr.toLowerCase().contains(name.toLowerCase())) {
                        if (foundName == null) {
                            foundName = name;
                        } else {
                            foundName = null;
                            break; // give up searching
                        }
                    }
                }
                if (foundName != null) {
                    order.setSellerId(sellers.get(foundName));
                }
            }
        }
        
        String pi[] = transactStr.split("Transaction ID: ");
        if (pi.length == 2) {
            String tid = pi[1].replaceFirst("==Payer.*$", "")
                    .replaceFirst(" *Authorization Code.*$", "");
            order.setTransactionId(tid);
            if (existingTIDs.contains(tid)) {
                return null; // this order has aleady been entered
            }
        }
        
        String prods[];
        int firstProd;
        if (productsStr.contains("\n")) {
            // Each product is on its own line, product # may either be at the 
            // beginning or as part of a Style:
            // Products are separated from other information by a line starting with Total:
            prods = productsStr.split("\\r*\\nTotal:")[0].split("\\r*\\n");
            firstProd = 0;
        } else {
            // All products are on one line, separated by #
            prods = productsStr.replaceFirst("Total: .*$", "").split("#");
            firstProd = 1;
        }
        
        if (prods.length > firstProd) {
            try {
                List<OrderProductInfo> opiList = new ArrayList<>();
                for (int i = firstProd; i < prods.length; i++) {
                    opiList.add(parseProduct(prods[i], saleProducts));
                }
                order.setProducts(opiList);
            } catch (IllegalArgumentException e) {
                order.setError(e.getMessage());
            }
        }
        String totalStr = productsStr.replaceAll("[\r\n]", "")
                .replaceFirst("^.*Total: \\$*", "")
                .replaceFirst("Transaction.*$", "")
                .replaceFirst(" USD.*$", "");
        
        order.setTotalSale(totalStr);
        
        return order;
    }
    
    // parse: 01 - DONATIONS (Amount: 5.00 USD, Quantity: 5) 
    // parse: Double Sided Yard Signs (Amount: 15.00 USD, Each: 1, Style: #56 Witch w/Flying Bat) 
    private static OrderProductInfo parseProduct(String productStr, Map<String, OrderProductInfo> saleProducts) {
        OrderProductInfo opi = new OrderProductInfo();
        
        if (productStr.contains("Style: #")) {
            opi.setNum(productStr.replaceAll("^.*Style: #", "").replaceAll(" .*$", ""));
        } else {
            opi.setNum(productStr.replaceAll(" .*$", "").replaceAll("#", ""));
        }
        OrderProductInfo saleProd = saleProducts.get(opi.getNum());
        if (saleProd == null) {
            throw new IllegalArgumentException("Order in previous row refers to a product (" + opi.getNum() + 
                    ") that is not in the current sale.");
        }
        opi.setId(saleProd.getId());
        String[] quantityNames = { "Quantity", "Each" };
        int quantity = 0;
        for (String qname : quantityNames) {
            try {
                String quanStr = productStr.replaceAll("^.*" + qname + ": ", "")
                        .replaceAll("\\).*$", "")
                        .replaceAll(",.*$", "");
                quantity = Integer.parseInt(quanStr);
                break;
            } catch (NumberFormatException e) {
                continue;
            }
        }
        if (quantity < 1) {
            throw new IllegalArgumentException("Cannot parse valid quantity from: " + productStr);
        }
        opi.setQuantity(quantity);
        
        String amtStr = productStr.replaceAll("^.*Amount: ", "").replaceAll(" USD.*$", "");
        Double price = Double.valueOf(amtStr);
        int priceInt = (int)(price * 100);
        int prodPriceInt = (int)(saleProd.getAmount() * 100);
        if (priceInt != prodPriceInt) {
            throw new IllegalArgumentException("Order in previous row has a price (" +
                    price + ") for product " + opi.getNum() + " that doesn't match the sale product price (" +
                    saleProd.getAmount() + ").");
        }
        opi.setAmount(price);
        
        return opi;
    }
    
    private static String truncateIfLongerThan(String s, int len) {
        return s.length() <= len ? s : s.substring(0, len - 1);
    }
    
    /** Creates a new instance of PlantSale */
    public PlantSale() {
    }
    
}
