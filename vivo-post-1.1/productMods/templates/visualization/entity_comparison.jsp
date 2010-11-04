<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>
<!--<script type="text/javascript" src="http://orderedlist.com/demos/quicksilverjs/javascripts/quicksilver.js"></script>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>-->
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="portalBean" value="${requestScope.portalBean}" />
<c:set var="themeDir">
	<c:out value="${portalBean.themeDir}" />
</c:set>
<c:set var='jsonContent' value='${requestScope.JsonContent}' />
<div id="body">
	<h1>Temporal Graph Visualization<span id="entitylevelheading"><i> School level</i></span></h1>
	<div id="leftblock">
		<h2>How do you want to compare?</h2>
		<select class="comparisonValues">
			<option value="Publications" selected="selected">Publications</option>
			<option value="Grants" disabled="disabled">Grants</option>
			<option value="People" disabled="disabled">People</option>
			<option value="Item4" disabled="disabled">Item4</option>
			<option value="Item5" disabled="disabled">Item5</option>
		</select>
		<br/>		
		<div id="paginatedTable">
		</div>
		<div id = "stopwordsdiv">
			* The entity types core:Person, foaf:Organization have been excluded as they are too general.
		</div>	
	</div>
		<div id="rightblock">
			<div id="graphContainer" style="width: 450px; height: 250px;"></div>
			<div id="yaxislabel"></div>
			<div id="bottom" style="width: 450px;">
				<div id="xaxislabel">Year</div>
				<button type ="button">clear</button>
				<h3><span id="comparisonParameter"></span></h3>
			<p class="displayCounter">You have selected <span id="counter">0</span> of a maximum <span
			id="total">10</span> <span id="entityleveltext"> schools</span> to compare.</p>

			</div>
		</div>		
</div>
<script type="text/javascript">
	
	$(document).ready(function() {

		var jsonString = '${jsonContent}';
		var jsonObject = {
				prepare : function(arg1){
					loadData(arg1);
				}
			};
		paginationDiv = $("#pagination");
		graphContainer = $("#graphContainer");
		tableDiv = $('#paginatedTable');
 		// initial display of the grid when the page loads
 		init(graphContainer);
		
		/*
		 * When the intra-entity parameters are clicked,
		 * update the status accordingly.	
		 */	        
        $("select.comparisonValues").click(function(){
            var selectedValue = $("select.comparisonValues option:selected").val();
			$("#comparisonParameter").text("Total Number of " + selectedValue);
			$('#yaxislabel').html("Number of " + selectedValue + lotsofSpaceCharacters).mbFlipText(false);
			$("span#paramdesc").text($("select.comparisonValues option:selected").val() + ' (desc)');	
			$("span#paramasc").text($("select.comparisonValues option:selected").val() + ' (asc)');	
        });

		//click event handler for clear button
		$("button").click(function(){
			//console.log("clear button is clicked!");
			clearRenderedObjects();
		});

		//click event handler for next/previous icons
		$('#datatable_previous').live('click', function(){
			populateMapOfCheckedEntities();
		});

		$('#datatable_next').live('click',function(){
			populateMapOfCheckedEntities();
		});
		
		$("input[type=checkbox].easyDeselectCheckbox").live('click', function(){
			
			var checkbox = $(this);
			var checkboxValue = $(this).attr("value");
			var linkedCheckbox = labelToCheckedEntities[checkboxValue];
			//console.log('checkbox value is '+ checkboxValue);
			var entityToBeRemoved = labelToEntityRecord[checkboxValue];

			if(!checkbox.is(':checked')){
				//console.log("Easy deselect checkbox is unclicked!");
				removeUsedColor(entityToBeRemoved);
				removeEntityUnChecked(renderedObjects, entityToBeRemoved);                          
             	removeGraphic(linkedCheckbox);
             	removeCheckBoxFromGlobalSet(linkedCheckbox);
             	$(linkedCheckbox).attr('checked', false);
                displayLineGraphs();
				updateCounter();				
    		}
		});
							
		//parse the json object and pass it to loadData
        jsonObject.prepare(jQuery.parseJSON(jsonString));

        /* 
         *  function to populate the labelToEntityRecord object with the
         *  values from the json file and
         *  dynamically generate checkboxes
         */
        function loadData(jsonData){
            
            var yearRange;

            $.each(jsonData, function(index, val){
                setOfLabels.push(val.label);
                labelToEntityRecord[val.label] = val;
            });

			getEntityVisMode(jsonData);
			prepareTableForDataTablePagination(jsonData);
			setEntityLevel();
            calcMinandMaxYears(labelToEntityRecord, year);
			yearRange = (year.max - year.min);

            setLineWidthAndTickSize(yearRange, FlotOptions);
        	paginationOptions.callback = pageSelectCallback;       

            
            /*
             * pageSelectCallback is a callback function that
             * creates the newContent div and inserts the corresponding html into it.
             * @param {Object} pageIndex
             * @param {Object} jquery object
             * @returns false to prevent infinite loop!
             */
            function pageSelectCallback(pageIndex, paginationDiv){

 				//createCheckBoxesInsidePaginatedDiv(pageIndex);
                /*
                 * When the elements in the paginated div
                 * are clicked this event handler is called
                 */
                $("input.if_clicked_on_school").live('click', function(){
                
                    var checkbox = $(this);
                    var checkboxValue = $(this).attr("value");
                    var entity = labelToEntityRecord[checkboxValue];
                    
					//Dynamically generate the bar, checkbox and label.

                    var bottomDiv = $("#bottom");
                    var hiddenLabel = createGraphic(entity, bottomDiv);

                    
                    var divBar = hiddenLabel.next();
                    var divLabel = hiddenLabel.prev();
                    var spanElement = divBar.next('span');

                    if (checkbox.is(':checked')) {
                    
						getNextFreeColor(entity);
						generateBarAndLabel(entity, divBar, divLabel,checkbox, spanElement) ; 
						renderLineGraph(renderedObjects, entity);
						                     
                    } else if (!checkbox.is(':checked')) {

							removeUsedColor(entity);
							removeEntityUnChecked(renderedObjects, entity);                          
                         	removeGraphic(checkbox);
                         	removeCheckBoxFromGlobalSet(checkbox);
                         
                        }
				    populateMapOfCheckedEntities();                    
                    displayLineGraphs();
					updateCounter(); 

                });
                
               return false;
            }  
	
			renderPaginatedDiv();
        }

        $('#livesearch').liveUpdate('#searchresult').focus(); 

	});
	
</script>
